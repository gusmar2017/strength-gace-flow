"""
Workout service for managing workouts and history.
"""

from datetime import datetime
from typing import Optional
import uuid

from app.config.firebase import get_firestore_client
from app.models.workout import (
    CyclePhase,
    IntensityLevel,
    Workout,
    WorkoutCategory,
    WorkoutHistory,
    WorkoutSummary,
)


# Placeholder workouts - these would normally come from Firestore
PLACEHOLDER_WORKOUTS: list[Workout] = [
    # Menstrual phase - low intensity
    Workout(
        id="w1",
        title="Gentle Flow Yoga",
        description="A calming yoga sequence perfect for the menstrual phase. Focus on gentle stretches and restorative poses to ease cramps and promote relaxation.",
        category=WorkoutCategory.YOGA,
        duration_minutes=20,
        intensity=IntensityLevel.LOW,
        recommended_phases=[CyclePhase.MENSTRUAL, CyclePhase.LUTEAL],
        instructor_name="Sarah Chen",
        equipment_needed=[],
        calories_estimate=80,
    ),
    Workout(
        id="w2",
        title="Restorative Stretching",
        description="Full body stretching routine to release tension and improve flexibility. Perfect for rest days or low-energy phases.",
        category=WorkoutCategory.STRETCHING,
        duration_minutes=15,
        intensity=IntensityLevel.LOW,
        recommended_phases=[CyclePhase.MENSTRUAL],
        instructor_name="Maya Johnson",
        equipment_needed=["yoga mat"],
        calories_estimate=50,
    ),
    Workout(
        id="w3",
        title="Mindful Walking",
        description="A guided walking meditation to get gentle movement while staying centered and calm.",
        category=WorkoutCategory.CARDIO,
        duration_minutes=20,
        intensity=IntensityLevel.LOW,
        recommended_phases=[CyclePhase.MENSTRUAL],
        instructor_name="SGF Team",
        equipment_needed=[],
        calories_estimate=70,
    ),
    # Follicular phase - medium intensity
    Workout(
        id="w4",
        title="Energizing Pilates",
        description="Build core strength and stability with this flowing Pilates routine. Great for the follicular phase when energy is rising.",
        category=WorkoutCategory.PILATES,
        duration_minutes=30,
        intensity=IntensityLevel.MEDIUM,
        recommended_phases=[CyclePhase.FOLLICULAR, CyclePhase.LUTEAL],
        instructor_name="Emma Roberts",
        equipment_needed=["yoga mat"],
        calories_estimate=150,
    ),
    Workout(
        id="w5",
        title="Dance Cardio Fun",
        description="Get your heart pumping with this fun dance cardio session. Learn easy-to-follow choreography while burning calories.",
        category=WorkoutCategory.DANCE,
        duration_minutes=25,
        intensity=IntensityLevel.MEDIUM,
        recommended_phases=[CyclePhase.FOLLICULAR, CyclePhase.OVULATORY],
        instructor_name="Aisha Williams",
        equipment_needed=[],
        calories_estimate=200,
    ),
    Workout(
        id="w6",
        title="Strength Foundations",
        description="Build functional strength with bodyweight exercises. Focus on proper form and controlled movements.",
        category=WorkoutCategory.STRENGTH,
        duration_minutes=35,
        intensity=IntensityLevel.MEDIUM,
        recommended_phases=[CyclePhase.FOLLICULAR],
        instructor_name="Jordan Lee",
        equipment_needed=["dumbbells"],
        calories_estimate=180,
    ),
    # Ovulatory phase - high intensity
    Workout(
        id="w7",
        title="Power HIIT",
        description="High-intensity interval training to maximize your peak energy levels. Push yourself with this challenging workout!",
        category=WorkoutCategory.HIIT,
        duration_minutes=25,
        intensity=IntensityLevel.HIGH,
        recommended_phases=[CyclePhase.OVULATORY],
        instructor_name="Marcus Chen",
        equipment_needed=[],
        calories_estimate=300,
    ),
    Workout(
        id="w8",
        title="Athletic Strength",
        description="Challenge yourself with compound movements and heavier weights. Perfect for your strongest days.",
        category=WorkoutCategory.STRENGTH,
        duration_minutes=40,
        intensity=IntensityLevel.HIGH,
        recommended_phases=[CyclePhase.OVULATORY],
        instructor_name="Jordan Lee",
        equipment_needed=["dumbbells", "resistance bands"],
        calories_estimate=280,
    ),
    Workout(
        id="w9",
        title="Cardio Blast",
        description="High-energy cardio workout combining jumping, running in place, and dynamic movements.",
        category=WorkoutCategory.CARDIO,
        duration_minutes=30,
        intensity=IntensityLevel.HIGH,
        recommended_phases=[CyclePhase.OVULATORY, CyclePhase.FOLLICULAR],
        instructor_name="Aisha Williams",
        equipment_needed=[],
        calories_estimate=320,
    ),
    # Luteal phase - medium to low
    Workout(
        id="w10",
        title="Barre Sculpt",
        description="Low-impact, high-results barre workout focusing on small, controlled movements for lean muscles.",
        category=WorkoutCategory.BARRE,
        duration_minutes=35,
        intensity=IntensityLevel.MEDIUM,
        recommended_phases=[CyclePhase.LUTEAL],
        instructor_name="Sophie Martin",
        equipment_needed=["chair or barre"],
        calories_estimate=160,
    ),
    Workout(
        id="w11",
        title="Stress Relief Yoga",
        description="Yoga flow designed to calm the nervous system and reduce luteal phase symptoms like bloating and mood swings.",
        category=WorkoutCategory.YOGA,
        duration_minutes=30,
        intensity=IntensityLevel.LOW,
        recommended_phases=[CyclePhase.LUTEAL, CyclePhase.MENSTRUAL],
        instructor_name="Sarah Chen",
        equipment_needed=["yoga mat"],
        calories_estimate=100,
    ),
    Workout(
        id="w12",
        title="Upper Body Strength",
        description="Focus on upper body with moderate weights. Great for the luteal phase when lower body may feel heavier.",
        category=WorkoutCategory.STRENGTH,
        duration_minutes=30,
        intensity=IntensityLevel.MEDIUM,
        recommended_phases=[CyclePhase.LUTEAL, CyclePhase.FOLLICULAR],
        instructor_name="Jordan Lee",
        equipment_needed=["dumbbells"],
        calories_estimate=170,
    ),
]


def _workout_to_summary(workout: Workout) -> WorkoutSummary:
    """Convert Workout to WorkoutSummary."""
    return WorkoutSummary(
        id=workout.id,
        title=workout.title,
        category=workout.category,
        duration_minutes=workout.duration_minutes,
        intensity=workout.intensity,
        thumbnail_url=workout.thumbnail_url,
        is_premium=workout.is_premium,
    )


async def get_all_workouts(
    category: Optional[WorkoutCategory] = None,
    intensity: Optional[IntensityLevel] = None,
    phase: Optional[CyclePhase] = None,
    limit: int = 20,
    offset: int = 0,
) -> tuple[list[WorkoutSummary], int]:
    """
    Get all workouts with optional filtering.

    Args:
        category: Filter by workout category
        intensity: Filter by intensity level
        phase: Filter by recommended cycle phase
        limit: Maximum results to return
        offset: Pagination offset

    Returns:
        Tuple of (workout summaries, total count)
    """
    filtered = PLACEHOLDER_WORKOUTS

    if category:
        filtered = [w for w in filtered if w.category == category]

    if intensity:
        filtered = [w for w in filtered if w.intensity == intensity]

    if phase:
        filtered = [w for w in filtered if phase in w.recommended_phases]

    total = len(filtered)
    paginated = filtered[offset : offset + limit]

    return [_workout_to_summary(w) for w in paginated], total


async def get_workout_by_id(workout_id: str) -> Optional[Workout]:
    """
    Get a single workout by ID.

    Args:
        workout_id: The workout ID

    Returns:
        Workout or None if not found
    """
    for workout in PLACEHOLDER_WORKOUTS:
        if workout.id == workout_id:
            return workout
    return None


async def get_recommended_workouts(
    phase: CyclePhase,
    limit: int = 4,
) -> list[WorkoutSummary]:
    """
    Get recommended workouts for a cycle phase.

    Args:
        phase: Current cycle phase
        limit: Maximum results

    Returns:
        List of recommended workout summaries
    """
    recommended = [w for w in PLACEHOLDER_WORKOUTS if phase in w.recommended_phases]
    return [_workout_to_summary(w) for w in recommended[:limit]]


async def log_workout_completion(
    user_id: str,
    workout_id: str,
    duration_minutes: Optional[int] = None,
    calories_burned: Optional[int] = None,
    notes: Optional[str] = None,
) -> WorkoutHistory:
    """
    Log a completed workout.

    Args:
        user_id: User ID
        workout_id: Workout ID
        duration_minutes: Actual duration (optional, uses workout default)
        calories_burned: Calories burned (optional)
        notes: User notes

    Returns:
        Created WorkoutHistory entry
    """
    db = get_firestore_client()
    workout = await get_workout_by_id(workout_id)

    if workout is None:
        raise ValueError("Workout not found")

    history_id = str(uuid.uuid4())
    now = datetime.utcnow()

    history_data = {
        "user_id": user_id,
        "workout_id": workout_id,
        "workout_title": workout.title,
        "duration_minutes": duration_minutes or workout.duration_minutes,
        "completed_at": now,
        "calories_burned": calories_burned or workout.calories_estimate,
        "notes": notes,
    }

    db.collection("users").document(user_id).collection("workoutHistory").document(
        history_id
    ).set(history_data)

    return WorkoutHistory(id=history_id, **history_data)


async def get_workout_history(
    user_id: str,
    limit: int = 20,
) -> tuple[list[WorkoutHistory], int, int]:
    """
    Get user's workout history.

    Args:
        user_id: User ID
        limit: Maximum results

    Returns:
        Tuple of (history list, total workouts, total minutes)
    """
    db = get_firestore_client()
    history_ref = (
        db.collection("users")
        .document(user_id)
        .collection("workoutHistory")
        .order_by("completed_at", direction="DESCENDING")
        .limit(limit)
    )

    history = []
    total_minutes = 0

    for doc in history_ref.stream():
        data = doc.to_dict()
        history.append(
            WorkoutHistory(
                id=doc.id,
                user_id=user_id,
                workout_id=data["workout_id"],
                workout_title=data["workout_title"],
                duration_minutes=data["duration_minutes"],
                completed_at=data["completed_at"],
                calories_burned=data.get("calories_burned"),
                notes=data.get("notes"),
            )
        )
        total_minutes += data["duration_minutes"]

    return history, len(history), total_minutes
