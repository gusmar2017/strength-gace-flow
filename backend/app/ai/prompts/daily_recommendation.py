"""
AI prompts for generating personalized workout recommendations.
"""

SYSTEM_PROMPT = """You are a knowledgeable fitness coach specializing in cycle-synced training for women.
Your role is to provide personalized workout recommendations based on the user's current menstrual cycle phase,
fitness level, goals, and available workouts.

You understand how hormone fluctuations affect energy levels, recovery, and optimal training intensity:
- Menstrual phase (days 1-5): Lower energy, focus on gentle movement and rest
- Follicular phase (days 6-13): Rising energy, great for trying new things and building intensity
- Ovulatory phase (days 14-16): Peak energy and strength, ideal for high-intensity workouts
- Luteal phase (days 17-28): Gradually decreasing energy, focus on strength and stability

Always be encouraging, supportive, and body-positive. Never use shame-based motivation."""


def build_recommendation_prompt(
    phase: str,
    cycle_day: int,
    fitness_level: str,
    goals: list[str],
    available_workouts: list[dict],
    recent_workouts: list[str] = None,
) -> str:
    """
    Build a prompt for generating workout recommendations.

    Args:
        phase: Current cycle phase (menstrual, follicular, ovulatory, luteal)
        cycle_day: Current day in cycle
        fitness_level: User's fitness level (beginner, intermediate, advanced)
        goals: User's fitness goals
        available_workouts: List of available workouts with details
        recent_workouts: Titles of recently completed workouts (to avoid repetition)

    Returns:
        Formatted prompt string
    """
    workouts_text = "\n".join([
        f"- {w['title']} ({w['category']}, {w['duration_minutes']} min, {w['intensity']} intensity)"
        for w in available_workouts
    ])

    recent_text = ""
    if recent_workouts:
        recent_text = f"\n\nRecently completed workouts (avoid recommending these): {', '.join(recent_workouts)}"

    goals_text = ", ".join(goals) if goals else "general fitness"

    return f"""Based on the user's profile and current cycle phase, recommend 3 workouts for today.

USER PROFILE:
- Cycle phase: {phase} (day {cycle_day})
- Fitness level: {fitness_level}
- Goals: {goals_text}
{recent_text}

AVAILABLE WORKOUTS:
{workouts_text}

Please provide:
1. A brief (2-3 sentence) personalized message about how they might be feeling today based on their cycle phase
2. Your top 3 workout recommendations from the available list, with a short reason for each
3. One self-care tip relevant to their current phase

Format your response as JSON:
{{
    "daily_message": "Your personalized message here",
    "recommendations": [
        {{"workout_title": "Exact Title", "reason": "Why this workout"}},
        {{"workout_title": "Exact Title", "reason": "Why this workout"}},
        {{"workout_title": "Exact Title", "reason": "Why this workout"}}
    ],
    "self_care_tip": "Your tip here"
}}

Only use workout titles exactly as they appear in the available workouts list."""


FALLBACK_MESSAGES = {
    "menstrual": {
        "daily_message": "During your menstrual phase, it's completely normal to feel like taking it easy. Listen to your body and honor what it needs today.",
        "self_care_tip": "Stay hydrated and consider a warm bath or heating pad if you're experiencing cramps."
    },
    "follicular": {
        "daily_message": "Your energy is on the rise! This is a great time to challenge yourself and try something new. Your body is primed for learning and building.",
        "self_care_tip": "Fuel your workouts with complex carbs and lean protein to support your increasing energy."
    },
    "ovulatory": {
        "daily_message": "You're at your peak! Take advantage of this high-energy window to push yourself. Your strength and endurance are at their best.",
        "self_care_tip": "This is the perfect time for social workouts or group fitness classes."
    },
    "luteal": {
        "daily_message": "As you move into your luteal phase, you might notice your energy shifting. Focus on strength work and listen to your body's signals.",
        "self_care_tip": "Prioritize sleep and consider adding magnesium-rich foods to help with any PMS symptoms."
    }
}
