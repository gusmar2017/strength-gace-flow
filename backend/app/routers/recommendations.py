"""
AI Recommendation API endpoints.
"""

from typing import Optional

from fastapi import APIRouter, HTTPException, Query, status
from pydantic import BaseModel

from app.middleware.auth import CurrentUser
from app.services import cycle_service, recommendation_service

router = APIRouter(prefix="/api/v1/recommendations", tags=["Recommendations"])


class WorkoutRecommendation(BaseModel):
    """Single workout recommendation."""

    workout_title: str
    workout_id: Optional[str] = None
    reason: str


class DailyRecommendationResponse(BaseModel):
    """Response for daily recommendations."""

    daily_message: str
    recommendations: list[WorkoutRecommendation]
    self_care_tip: str
    phase: str
    cycle_day: int


@router.get("/today", response_model=DailyRecommendationResponse)
async def get_today_recommendations(user: CurrentUser):
    """
    Get AI-powered workout recommendations for today.

    Based on the user's current cycle phase, fitness level, and goals,
    returns personalized workout recommendations and wellness tips.
    """
    # Get current cycle info
    cycle_info = await cycle_service.get_current_cycle_info(user.uid)

    if cycle_info is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No cycle data found. Please log your first period to get recommendations.",
        )

    # Get AI recommendations
    result = await recommendation_service.get_daily_recommendations(
        user_id=user.uid,
        phase=cycle_info.cycle.current_phase.value,
        cycle_day=cycle_info.cycle.cycle_day,
    )

    if result is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate recommendations.",
        )

    # Build response
    recommendations = []
    for i, rec in enumerate(result.recommendations):
        workout_id = result.workout_ids[i] if i < len(result.workout_ids) else None
        recommendations.append(
            WorkoutRecommendation(
                workout_title=rec.get("workout_title", ""),
                workout_id=workout_id,
                reason=rec.get("reason", ""),
            )
        )

    return DailyRecommendationResponse(
        daily_message=result.daily_message,
        recommendations=recommendations,
        self_care_tip=result.self_care_tip,
        phase=cycle_info.cycle.current_phase.value,
        cycle_day=cycle_info.cycle.cycle_day,
    )


@router.get("/phase/{phase}", response_model=DailyRecommendationResponse)
async def get_phase_recommendations(
    user: CurrentUser,
    phase: str,
    cycle_day: int = Query(default=1, ge=1, le=45),
):
    """
    Get recommendations for a specific cycle phase.

    Useful for exploring what workouts are recommended for different phases.
    """
    valid_phases = ["menstrual", "follicular", "ovulatory", "luteal"]
    if phase not in valid_phases:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid phase. Must be one of: {', '.join(valid_phases)}",
        )

    result = await recommendation_service.get_daily_recommendations(
        user_id=user.uid,
        phase=phase,
        cycle_day=cycle_day,
    )

    if result is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate recommendations.",
        )

    recommendations = []
    for i, rec in enumerate(result.recommendations):
        workout_id = result.workout_ids[i] if i < len(result.workout_ids) else None
        recommendations.append(
            WorkoutRecommendation(
                workout_title=rec.get("workout_title", ""),
                workout_id=workout_id,
                reason=rec.get("reason", ""),
            )
        )

    return DailyRecommendationResponse(
        daily_message=result.daily_message,
        recommendations=recommendations,
        self_care_tip=result.self_care_tip,
        phase=phase,
        cycle_day=cycle_day,
    )
