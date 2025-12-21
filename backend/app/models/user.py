"""
User models for API requests and responses.
"""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class FitnessLevel(str, Enum):
    """User's fitness experience level."""
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"


class FitnessGoal(str, Enum):
    """User's fitness goals."""
    BUILD_STRENGTH = "build_strength"
    IMPROVE_FLEXIBILITY = "improve_flexibility"
    REDUCE_STRESS = "reduce_stress"
    POSTPARTUM_RECOVERY = "postpartum_recovery"
    HORMONE_BALANCE = "hormone_balance"
    CONSISTENCY = "consistency"


class SubscriptionStatus(str, Enum):
    """User's subscription status."""
    NONE = "none"
    TRIAL = "trial"
    ACTIVE = "active"
    EXPIRED = "expired"
    CANCELLED = "cancelled"


class UserBase(BaseModel):
    """Base user fields."""
    display_name: Optional[str] = None
    fitness_level: Optional[FitnessLevel] = None
    goals: list[FitnessGoal] = Field(default_factory=list)
    average_cycle_length: int = Field(default=28, ge=21, le=45)
    average_period_length: int = Field(default=5, ge=2, le=10)
    cycle_tracking_enabled: bool = True
    notifications_enabled: bool = True


class UserCreate(UserBase):
    """Fields for creating a new user profile."""
    pass


class UserUpdate(BaseModel):
    """Fields for updating a user profile. All optional."""
    display_name: Optional[str] = None
    fitness_level: Optional[FitnessLevel] = None
    goals: Optional[list[FitnessGoal]] = None
    average_cycle_length: Optional[int] = Field(default=None, ge=21, le=45)
    average_period_length: Optional[int] = Field(default=None, ge=2, le=10)
    cycle_tracking_enabled: Optional[bool] = None
    notifications_enabled: Optional[bool] = None
    last_period_start_date: Optional[datetime] = None


class UserProfile(UserBase):
    """Full user profile response."""
    id: str
    email: Optional[str] = None
    profile_image_url: Optional[str] = None
    last_period_start_date: Optional[datetime] = None
    subscription_status: SubscriptionStatus = SubscriptionStatus.NONE
    subscription_expires_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    onboarding_completed: bool = False

    class Config:
        from_attributes = True


class UserProfileResponse(BaseModel):
    """API response wrapper for user profile."""
    user: UserProfile
