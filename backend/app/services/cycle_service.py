"""
Cycle tracking service for Firestore operations.
"""

from datetime import date, datetime
from typing import Optional
import uuid

from app.config.firebase import get_firestore_client
from app.models.cycle import (
    CycleData,
    CycleInfo,
    CycleInfoResponse,
    LogPeriodRequest,
    PhasePrediction,
)
from app.services import user_service
from app.utils.cycle_calculations import (
    calculate_current_phase,
    estimate_next_period,
    predict_phases,
)


async def get_current_cycle_info(user_id: str) -> Optional[CycleInfoResponse]:
    """
    Get current cycle phase information for a user.

    Args:
        user_id: Firebase user UID

    Returns:
        CycleInfoResponse or None if user not found or no period logged
    """
    # Get user profile for cycle settings
    user = await user_service.get_user_profile(user_id)
    if user is None:
        return None

    # Check if user has logged a period
    if user.last_period_start_date is None:
        return None

    # Calculate current phase
    last_period = user.last_period_start_date.date() if isinstance(
        user.last_period_start_date, datetime
    ) else user.last_period_start_date

    cycle_info = calculate_current_phase(
        last_period_start=last_period,
        average_cycle_length=user.average_cycle_length,
        average_period_length=user.average_period_length,
    )

    return CycleInfoResponse(
        cycle=cycle_info,
        last_period_start=last_period,
        average_cycle_length=user.average_cycle_length,
        average_period_length=user.average_period_length,
    )


async def log_period(user_id: str, data: LogPeriodRequest) -> CycleData:
    """
    Log a new period start date.

    This also updates the user's last_period_start_date and
    closes any open previous cycle.

    Args:
        user_id: Firebase user UID
        data: Period logging request

    Returns:
        Created CycleData entry
    """
    db = get_firestore_client()
    user_ref = db.collection("users").document(user_id)
    cycles_ref = user_ref.collection("cycleData")

    # Get user profile
    user = await user_service.get_user_profile(user_id)
    if user is None:
        raise ValueError("User not found")

    now = datetime.utcnow()
    cycle_id = str(uuid.uuid4())

    # If there's a previous cycle, close it
    if user.last_period_start_date:
        previous_start = user.last_period_start_date.date() if isinstance(
            user.last_period_start_date, datetime
        ) else user.last_period_start_date

        # Find the open cycle and close it
        query = cycles_ref.where("end_date", "==", None).limit(1)
        for doc in query.stream():
            cycle_length = (data.start_date - previous_start).days
            doc.reference.update({
                "end_date": data.start_date,
                "cycle_length": cycle_length,
            })

    # Create new cycle entry
    cycle_data = {
        "user_id": user_id,
        "start_date": datetime.combine(data.start_date, datetime.min.time()),
        "end_date": None,  # Will be set when next period is logged
        "period_end_date": None,
        "cycle_length": None,
        "notes": data.notes,
        "created_at": now,
    }

    cycles_ref.document(cycle_id).set(cycle_data)

    # Update user's last period start date
    user_ref.update({
        "last_period_start_date": datetime.combine(data.start_date, datetime.min.time()),
        "updated_at": now,
    })

    return CycleData(
        id=cycle_id,
        user_id=user_id,
        start_date=data.start_date,
        end_date=None,
        period_end_date=None,
        cycle_length=None,
        notes=data.notes,
        created_at=now,
    )


async def get_cycle_history(user_id: str, limit: int = 12) -> list[CycleData]:
    """
    Get user's cycle history.

    Args:
        user_id: Firebase user UID
        limit: Maximum number of cycles to return

    Returns:
        List of CycleData entries, newest first
    """
    db = get_firestore_client()
    cycles_ref = (
        db.collection("users")
        .document(user_id)
        .collection("cycleData")
        .order_by("start_date", direction="DESCENDING")
        .limit(limit)
    )

    cycles = []
    for doc in cycles_ref.stream():
        data = doc.to_dict()
        cycles.append(
            CycleData(
                id=doc.id,
                user_id=user_id,
                start_date=data["start_date"].date() if data.get("start_date") else None,
                end_date=data["end_date"].date() if data.get("end_date") else None,
                period_end_date=data["period_end_date"].date() if data.get("period_end_date") else None,
                cycle_length=data.get("cycle_length"),
                notes=data.get("notes"),
                created_at=data.get("created_at", datetime.utcnow()),
            )
        )

    return cycles


async def get_cycle_predictions(
    user_id: str,
    days_ahead: int = 30,
) -> tuple[list[PhasePrediction], Optional[date]]:
    """
    Get cycle phase predictions for upcoming days.

    Args:
        user_id: Firebase user UID
        days_ahead: Number of days to predict

    Returns:
        Tuple of (predictions list, estimated next period date)
    """
    user = await user_service.get_user_profile(user_id)
    if user is None or user.last_period_start_date is None:
        return [], None

    last_period = user.last_period_start_date.date() if isinstance(
        user.last_period_start_date, datetime
    ) else user.last_period_start_date

    predictions = predict_phases(
        last_period_start=last_period,
        average_cycle_length=user.average_cycle_length,
        average_period_length=user.average_period_length,
        days_ahead=days_ahead,
    )

    next_period = estimate_next_period(
        last_period_start=last_period,
        average_cycle_length=user.average_cycle_length,
    )

    return predictions, next_period


async def calculate_average_cycle_length(user_id: str) -> Optional[int]:
    """
    Calculate user's average cycle length from history.

    Args:
        user_id: Firebase user UID

    Returns:
        Average cycle length or None if insufficient data
    """
    cycles = await get_cycle_history(user_id, limit=6)

    # Need at least 2 completed cycles to calculate average
    completed_cycles = [c for c in cycles if c.cycle_length is not None]
    if len(completed_cycles) < 2:
        return None

    total_length = sum(c.cycle_length for c in completed_cycles)
    return round(total_length / len(completed_cycles))
