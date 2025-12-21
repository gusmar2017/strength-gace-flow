"""
Workout models for the workout library.
"""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class WorkoutCategory(str, Enum):
    """Workout category types."""

    STRENGTH = "strength"
    CARDIO = "cardio"
    YOGA = "yoga"
    PILATES = "pilates"
    HIIT = "hiit"
    STRETCHING = "stretching"
    BARRE = "barre"
    DANCE = "dance"


class IntensityLevel(str, Enum):
    """Workout intensity levels."""

    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class CyclePhase(str, Enum):
    """Menstrual cycle phases."""

    MENSTRUAL = "menstrual"
    FOLLICULAR = "follicular"
    OVULATORY = "ovulatory"
    LUTEAL = "luteal"


class Workout(BaseModel):
    """Workout model."""

    id: str
    title: str
    description: str
    category: WorkoutCategory
    duration_minutes: int = Field(ge=5, le=120)
    intensity: IntensityLevel
    recommended_phases: list[CyclePhase]
    thumbnail_url: Optional[str] = None
    video_url: Optional[str] = None  # Placeholder for now
    instructor_name: str = "SGF Team"
    equipment_needed: list[str] = []
    calories_estimate: Optional[int] = None
    is_premium: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)


class WorkoutSummary(BaseModel):
    """Summarized workout for list views."""

    id: str
    title: str
    category: WorkoutCategory
    duration_minutes: int
    intensity: IntensityLevel
    thumbnail_url: Optional[str] = None
    is_premium: bool = False


class WorkoutListResponse(BaseModel):
    """Response for workout list endpoint."""

    workouts: list[WorkoutSummary]
    total: int
    has_more: bool = False


class WorkoutDetailResponse(BaseModel):
    """Response for single workout endpoint."""

    workout: Workout


class WorkoutHistory(BaseModel):
    """User's workout completion history."""

    id: str
    user_id: str
    workout_id: str
    workout_title: str
    duration_minutes: int
    completed_at: datetime
    calories_burned: Optional[int] = None
    notes: Optional[str] = None


class LogWorkoutRequest(BaseModel):
    """Request to log a completed workout."""

    workout_id: str
    duration_minutes: Optional[int] = None
    calories_burned: Optional[int] = None
    notes: Optional[str] = None


class WorkoutHistoryResponse(BaseModel):
    """Response for workout history endpoint."""

    history: list[WorkoutHistory]
    total_workouts: int
    total_minutes: int
