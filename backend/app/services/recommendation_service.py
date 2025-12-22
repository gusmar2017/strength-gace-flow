"""
AI-powered workout recommendation service.
"""

import json
from typing import Optional

from anthropic import Anthropic

from app.ai.prompts.daily_recommendation import (
    FALLBACK_MESSAGES,
    SYSTEM_PROMPT,
    build_recommendation_prompt,
)
from app.config.settings import get_settings
from app.models.workout import CyclePhase, Workout
from app.services import user_service, workout_service


class RecommendationResult:
    """Result from AI recommendation."""

    def __init__(
        self,
        daily_message: str,
        recommendations: list[dict],
        self_care_tip: str,
        workout_ids: list[str],
    ):
        self.daily_message = daily_message
        self.recommendations = recommendations
        self.self_care_tip = self_care_tip
        self.workout_ids = workout_ids


async def get_daily_recommendations(
    user_id: str,
    phase: str,
    cycle_day: int,
) -> Optional[RecommendationResult]:
    """
    Get AI-powered daily workout recommendations.

    Args:
        user_id: User ID
        phase: Current cycle phase
        cycle_day: Current day in cycle

    Returns:
        RecommendationResult or None if failed
    """
    settings = get_settings()

    # Get user profile
    user = await user_service.get_user_profile(user_id)
    if user is None:
        return None

    # Get available workouts for this phase
    phase_enum = CyclePhase(phase)
    workouts, _ = await workout_service.get_all_workouts(phase=phase_enum, limit=20)

    # Convert to dict format for prompt
    available_workouts = [
        {
            "id": w.id,
            "title": w.title,
            "category": w.category.value,
            "duration_minutes": w.duration_minutes,
            "intensity": w.intensity.value,
        }
        for w in workouts
    ]

    # Get recent workout titles to avoid repetition
    history, _, _ = await workout_service.get_workout_history(user_id, limit=5)
    recent_titles = [h.workout_title for h in history]

    # Build prompt
    fitness_level = user.fitness_level.value if user.fitness_level else "intermediate"
    goals = [g.value for g in user.goals] if user.goals else []

    # Check if API key is available
    if not settings.anthropic_api_key:
        # Return fallback recommendations without AI
        return _get_fallback_recommendations(phase, available_workouts)

    try:
        # Call Claude API
        client = Anthropic(api_key=settings.anthropic_api_key)

        prompt = build_recommendation_prompt(
            phase=phase,
            cycle_day=cycle_day,
            fitness_level=fitness_level,
            goals=goals,
            available_workouts=available_workouts,
            recent_workouts=recent_titles,
        )

        message = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            messages=[{"role": "user", "content": prompt}],
        )

        # Parse response
        response_text = message.content[0].text

        # Extract JSON from response
        try:
            # Try to parse directly
            result = json.loads(response_text)
        except json.JSONDecodeError:
            # Try to find JSON in the response
            import re
            json_match = re.search(r'\{[\s\S]*\}', response_text)
            if json_match:
                result = json.loads(json_match.group())
            else:
                return _get_fallback_recommendations(phase, available_workouts)

        # Map workout titles to IDs
        workout_ids = []
        for rec in result.get("recommendations", []):
            title = rec.get("workout_title", "")
            for w in available_workouts:
                if w["title"].lower() == title.lower():
                    workout_ids.append(w["id"])
                    break

        return RecommendationResult(
            daily_message=result.get("daily_message", FALLBACK_MESSAGES[phase]["daily_message"]),
            recommendations=result.get("recommendations", []),
            self_care_tip=result.get("self_care_tip", FALLBACK_MESSAGES[phase]["self_care_tip"]),
            workout_ids=workout_ids,
        )

    except Exception as e:
        print(f"AI recommendation failed: {e}")
        return _get_fallback_recommendations(phase, available_workouts)


def _get_fallback_recommendations(
    phase: str,
    available_workouts: list[dict],
) -> RecommendationResult:
    """
    Get fallback recommendations when AI is unavailable.

    Args:
        phase: Current cycle phase
        available_workouts: List of available workouts

    Returns:
        RecommendationResult with fallback content
    """
    fallback = FALLBACK_MESSAGES.get(phase, FALLBACK_MESSAGES["follicular"])

    # Pick top 3 workouts
    top_workouts = available_workouts[:3]
    recommendations = [
        {"workout_title": w["title"], "reason": f"Great {w['intensity']} intensity {w['category']} for your {phase} phase"}
        for w in top_workouts
    ]
    workout_ids = [w["id"] for w in top_workouts]

    return RecommendationResult(
        daily_message=fallback["daily_message"],
        recommendations=recommendations,
        self_care_tip=fallback["self_care_tip"],
        workout_ids=workout_ids,
    )
