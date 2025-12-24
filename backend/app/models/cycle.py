"""
Cycle tracking models for API requests and responses.
"""

from datetime import date, datetime
from enum import Enum
from typing import Literal, Optional

from pydantic import BaseModel, Field


class CyclePhase(str, Enum):
    """Menstrual cycle phases."""
    MENSTRUAL = "menstrual"
    FOLLICULAR = "follicular"
    OVULATORY = "ovulatory"
    LUTEAL = "luteal"

    @property
    def display_name(self) -> str:
        """Human-readable phase name."""
        return self.value.capitalize()

    @property
    def description(self) -> str:
        """Phase description with guidance."""
        descriptions = {
            "menstrual": "Rest and restore. Honor lower energy with gentle movement.",
            "follicular": "Energy is rising. Great time to try new things and build strength.",
            "ovulatory": "Peak energy. Embrace challenging workouts and social movement.",
            "luteal": "Winding down. Focus on steady, grounding practices.",
        }
        return descriptions[self.value]

    @property
    def recommended_intensity(self) -> str:
        """Recommended workout intensity for this phase."""
        intensities = {
            "menstrual": "low",
            "follicular": "medium",
            "ovulatory": "high",
            "luteal": "medium",
        }
        return intensities[self.value]


class IntensityLevel(str, Enum):
    """Workout intensity levels."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class CycleInfo(BaseModel):
    """Current cycle phase information."""
    current_phase: CyclePhase
    cycle_day: int = Field(ge=1, le=45)
    days_until_next_phase: int = Field(ge=0)
    next_phase: CyclePhase
    confidence: Literal["high", "medium", "low"]

    # Additional context
    phase_display_name: str
    phase_description: str
    recommended_intensity: str


class CycleInfoResponse(BaseModel):
    """API response for current cycle info."""
    cycle: CycleInfo
    last_period_start: Optional[date] = None
    average_cycle_length: int
    average_period_length: int


class LogPeriodRequest(BaseModel):
    """Request to log period start date."""
    start_date: date
    notes: Optional[str] = None


class UpdateCycleRequest(BaseModel):
    """Request to update a cycle entry."""
    start_date: Optional[date] = None
    period_end_date: Optional[date] = None
    notes: Optional[str] = None


class CycleData(BaseModel):
    """Historical cycle data."""
    id: str
    user_id: str
    start_date: date
    end_date: Optional[date] = None
    period_end_date: Optional[date] = None
    cycle_length: Optional[int] = None
    notes: Optional[str] = None
    created_at: datetime


class CycleHistoryResponse(BaseModel):
    """API response for cycle history."""
    cycles: list[CycleData]
    average_cycle_length: int
    total_cycles_logged: int


class PhasePrediction(BaseModel):
    """Predicted phase for a future date."""
    date: date
    predicted_phase: CyclePhase
    cycle_day: int


class CyclePredictionsResponse(BaseModel):
    """API response for cycle predictions."""
    predictions: list[PhasePrediction]
    next_period_start: Optional[date] = None
