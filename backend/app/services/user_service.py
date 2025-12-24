"""
User service for Firestore operations.
"""

from datetime import datetime
from typing import Optional

from google.cloud.firestore_v1 import DocumentSnapshot

from app.config.firebase import get_firestore_client
from app.models.user import (
    FitnessGoal,
    FitnessLevel,
    SubscriptionStatus,
    UserCreate,
    UserProfile,
    UserUpdate,
)


def _doc_to_user_profile(doc: DocumentSnapshot, user_id: str) -> Optional[UserProfile]:
    """Convert Firestore document to UserProfile model."""
    if not doc.exists:
        return None

    data = doc.to_dict()

    # Parse enums safely
    fitness_level = None
    if data.get("fitness_level"):
        try:
            fitness_level = FitnessLevel(data["fitness_level"])
        except ValueError:
            pass

    goals = []
    for goal in data.get("goals", []):
        try:
            goals.append(FitnessGoal(goal))
        except ValueError:
            pass

    subscription_status = SubscriptionStatus.NONE
    if data.get("subscription_status"):
        try:
            subscription_status = SubscriptionStatus(data["subscription_status"])
        except ValueError:
            pass

    return UserProfile(
        id=user_id,
        email=data.get("email"),
        display_name=data.get("display_name"),
        profile_image_url=data.get("profile_image_url"),
        fitness_level=fitness_level,
        goals=goals,
        average_cycle_length=data.get("average_cycle_length", 28),
        average_period_length=data.get("average_period_length", 5),
        cycle_tracking_enabled=data.get("cycle_tracking_enabled", True),
        notifications_enabled=data.get("notifications_enabled", True),
        last_period_start_date=data.get("last_period_start_date"),
        subscription_status=subscription_status,
        subscription_expires_at=data.get("subscription_expires_at"),
        created_at=data.get("created_at", datetime.utcnow()),
        updated_at=data.get("updated_at", datetime.utcnow()),
        onboarding_completed=data.get("onboarding_completed", False),
    )


async def get_user_profile(user_id: str) -> Optional[UserProfile]:
    """
    Get user profile from Firestore.

    Args:
        user_id: Firebase user UID

    Returns:
        UserProfile or None if not found
    """
    db = get_firestore_client()
    doc = db.collection("users").document(user_id).get()
    return _doc_to_user_profile(doc, user_id)


async def create_user_profile(
    user_id: str,
    email: Optional[str],
    data: UserCreate,
) -> UserProfile:
    """
    Create a new user profile in Firestore.

    Args:
        user_id: Firebase user UID
        email: User's email from Firebase Auth
        data: User creation data

    Returns:
        Created UserProfile
    """
    db = get_firestore_client()
    now = datetime.utcnow()

    profile_data = {
        "email": email,
        "display_name": data.display_name,
        "fitness_level": data.fitness_level.value if data.fitness_level else None,
        "goals": [g.value for g in data.goals],
        "average_cycle_length": data.average_cycle_length,
        "average_period_length": data.average_period_length,
        "cycle_tracking_enabled": data.cycle_tracking_enabled,
        "notifications_enabled": data.notifications_enabled,
        "subscription_status": SubscriptionStatus.NONE.value,
        "onboarding_completed": False,
        "created_at": now,
        "updated_at": now,
    }

    db.collection("users").document(user_id).set(profile_data)

    # Initialize cycle tracking with historical dates if provided
    if data.initial_cycle_dates:
        from app.services import cycle_service
        await cycle_service.initialize_cycle_tracking(user_id, data.initial_cycle_dates)

    return UserProfile(
        id=user_id,
        email=email,
        display_name=data.display_name,
        fitness_level=data.fitness_level,
        goals=data.goals,
        average_cycle_length=data.average_cycle_length,
        average_period_length=data.average_period_length,
        cycle_tracking_enabled=data.cycle_tracking_enabled,
        notifications_enabled=data.notifications_enabled,
        subscription_status=SubscriptionStatus.NONE,
        created_at=now,
        updated_at=now,
        onboarding_completed=False,
    )


async def update_user_profile(
    user_id: str,
    data: UserUpdate,
) -> Optional[UserProfile]:
    """
    Update user profile in Firestore.

    Args:
        user_id: Firebase user UID
        data: Fields to update

    Returns:
        Updated UserProfile or None if not found
    """
    db = get_firestore_client()
    doc_ref = db.collection("users").document(user_id)

    # Check if user exists
    if not doc_ref.get().exists:
        return None

    # Build update dict with only provided fields
    update_data = {"updated_at": datetime.utcnow()}

    if data.display_name is not None:
        update_data["display_name"] = data.display_name

    if data.fitness_level is not None:
        update_data["fitness_level"] = data.fitness_level.value

    if data.goals is not None:
        update_data["goals"] = [g.value for g in data.goals]

    if data.average_cycle_length is not None:
        update_data["average_cycle_length"] = data.average_cycle_length

    if data.average_period_length is not None:
        update_data["average_period_length"] = data.average_period_length

    if data.cycle_tracking_enabled is not None:
        update_data["cycle_tracking_enabled"] = data.cycle_tracking_enabled

    if data.notifications_enabled is not None:
        update_data["notifications_enabled"] = data.notifications_enabled

    if data.last_period_start_date is not None:
        update_data["last_period_start_date"] = data.last_period_start_date

    # Check if onboarding should be marked complete
    # (has display_name, fitness_level, and goals)
    doc = doc_ref.get().to_dict()
    has_name = update_data.get("display_name") or doc.get("display_name")
    has_level = update_data.get("fitness_level") or doc.get("fitness_level")
    has_goals = update_data.get("goals") or doc.get("goals")

    if has_name and has_level and has_goals:
        update_data["onboarding_completed"] = True

    doc_ref.update(update_data)

    return await get_user_profile(user_id)


async def delete_user_profile(user_id: str) -> bool:
    """
    Delete user profile from Firestore.

    Args:
        user_id: Firebase user UID

    Returns:
        True if deleted, False if not found
    """
    db = get_firestore_client()
    doc_ref = db.collection("users").document(user_id)

    if not doc_ref.get().exists:
        return False

    # Delete subcollections first
    for subcollection in ["cycleData", "workoutHistory", "preferences"]:
        subcol_ref = doc_ref.collection(subcollection)
        for doc in subcol_ref.stream():
            doc.reference.delete()

    # Delete the user document
    doc_ref.delete()
    return True
