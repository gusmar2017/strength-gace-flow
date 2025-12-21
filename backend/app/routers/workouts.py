"""
Workout API endpoints.
"""

from typing import Optional

from fastapi import APIRouter, HTTPException, Query, status

from app.middleware.auth import CurrentUser
from app.models.workout import (
    CyclePhase,
    IntensityLevel,
    LogWorkoutRequest,
    WorkoutCategory,
    WorkoutDetailResponse,
    WorkoutHistory,
    WorkoutHistoryResponse,
    WorkoutListResponse,
)
from app.services import workout_service

router = APIRouter(prefix="/api/v1/workouts", tags=["Workouts"])


@router.get("", response_model=WorkoutListResponse)
async def get_workouts(
    user: CurrentUser,
    category: Optional[WorkoutCategory] = Query(default=None),
    intensity: Optional[IntensityLevel] = Query(default=None),
    phase: Optional[CyclePhase] = Query(default=None),
    limit: int = Query(default=20, ge=1, le=50),
    offset: int = Query(default=0, ge=0),
):
    """
    Get all workouts with optional filters.

    Filter by category, intensity level, or recommended cycle phase.
    """
    workouts, total = await workout_service.get_all_workouts(
        category=category,
        intensity=intensity,
        phase=phase,
        limit=limit,
        offset=offset,
    )

    return WorkoutListResponse(
        workouts=workouts,
        total=total,
        has_more=(offset + len(workouts)) < total,
    )


@router.get("/recommended", response_model=WorkoutListResponse)
async def get_recommended_workouts(
    user: CurrentUser,
    phase: CyclePhase = Query(..., description="Current cycle phase"),
    limit: int = Query(default=4, ge=1, le=10),
):
    """
    Get recommended workouts for a specific cycle phase.

    Returns workouts best suited for the user's current phase.
    """
    workouts = await workout_service.get_recommended_workouts(phase=phase, limit=limit)

    return WorkoutListResponse(
        workouts=workouts,
        total=len(workouts),
        has_more=False,
    )


@router.get("/{workout_id}", response_model=WorkoutDetailResponse)
async def get_workout(
    user: CurrentUser,
    workout_id: str,
):
    """
    Get a single workout by ID.

    Returns full workout details including description and video URL.
    """
    workout = await workout_service.get_workout_by_id(workout_id)

    if workout is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workout not found",
        )

    return WorkoutDetailResponse(workout=workout)


@router.post("/history", response_model=WorkoutHistory, status_code=status.HTTP_201_CREATED)
async def log_workout(
    user: CurrentUser,
    data: LogWorkoutRequest,
):
    """
    Log a completed workout.

    Records the workout in the user's history for tracking progress.
    """
    try:
        history = await workout_service.log_workout_completion(
            user_id=user.uid,
            workout_id=data.workout_id,
            duration_minutes=data.duration_minutes,
            calories_burned=data.calories_burned,
            notes=data.notes,
        )
        return history
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.get("/history/me", response_model=WorkoutHistoryResponse)
async def get_my_workout_history(
    user: CurrentUser,
    limit: int = Query(default=20, ge=1, le=50),
):
    """
    Get the current user's workout history.

    Returns completed workouts sorted by most recent.
    """
    history, total, total_minutes = await workout_service.get_workout_history(
        user_id=user.uid,
        limit=limit,
    )

    return WorkoutHistoryResponse(
        history=history,
        total_workouts=total,
        total_minutes=total_minutes,
    )
