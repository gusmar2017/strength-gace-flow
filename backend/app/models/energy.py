"""
Energy tracking models for API requests and responses.
"""

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, Field


class LogEnergyRequest(BaseModel):
    """Request to log daily energy level."""
    date: date
    score: int = Field(..., ge=1, le=10, description="Energy level from 1-10")
    notes: Optional[str] = Field(None, max_length=500)


class EnergyLog(BaseModel):
    """Single energy log entry."""
    id: str
    user_id: str
    date: date
    score: int
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class EnergyLogResponse(BaseModel):
    """API response for logging energy."""
    energy: EnergyLog


class EnergyHistoryResponse(BaseModel):
    """API response for energy history."""
    entries: list[EnergyLog]
    average_score: float
    total_logs: int
