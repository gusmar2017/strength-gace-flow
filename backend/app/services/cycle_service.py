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
    UpdateCycleRequest,
)
from app.models.user import UserUpdate
from app.services import user_service
from app.utils.cycle_calculations import (
    calculate_current_phase,
    calculate_median,
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
    Get cycle phase predictions for upcoming days and full historical cycles.

    Args:
        user_id: Firebase user UID
        days_ahead: Number of days to predict forward

    Returns:
        Tuple of (predictions list, estimated next period date)
    """
    user = await user_service.get_user_profile(user_id)
    if user is None or user.last_period_start_date is None:
        return [], None

    last_period = user.last_period_start_date.date() if isinstance(
        user.last_period_start_date, datetime
    ) else user.last_period_start_date

    # Get all cycle history to determine how far back to predict
    cycles = await get_cycle_history(user_id, limit=24)

    # Find the earliest cycle start date
    earliest_cycle_date = None
    if cycles:
        earliest_cycle_date = min(cycle.start_date for cycle in cycles if cycle.start_date)

    predictions = predict_phases(
        last_period_start=last_period,
        average_cycle_length=user.average_cycle_length,
        average_period_length=user.average_period_length,
        days_ahead=days_ahead,
        earliest_cycle_date=earliest_cycle_date,
    )

    next_period = estimate_next_period(
        last_period_start=last_period,
        average_cycle_length=user.average_cycle_length,
    )

    return predictions, next_period


async def calculate_average_cycle_length(user_id: str) -> Optional[int]:
    """
    Calculate user's average cycle length from history using median.

    Median is more robust to outliers than mean.

    Args:
        user_id: Firebase user UID

    Returns:
        Average cycle length (median) or None if insufficient data
    """
    cycles = await get_cycle_history(user_id, limit=6)

    # Need at least 2 completed cycles to calculate average
    completed_cycles = [c for c in cycles if c.cycle_length is not None]
    if len(completed_cycles) < 2:
        return None

    cycle_lengths = [c.cycle_length for c in completed_cycles]
    return calculate_median(cycle_lengths)


async def initialize_cycle_tracking(
    user_id: str,
    initial_dates: list[date],
) -> None:
    """
    Initialize cycle tracking with historical dates from onboarding.

    Creates cycle entries for each date and calculates averages.

    Args:
        user_id: Firebase user UID
        initial_dates: List of 1-3 period start dates
    """
    if not initial_dates:
        return

    # Sort dates chronologically (oldest first)
    sorted_dates = sorted(initial_dates)

    db = get_firestore_client()
    user_ref = db.collection("users").document(user_id)
    cycles_ref = user_ref.collection("cycleData")
    now = datetime.utcnow()

    cycle_lengths = []

    # Create cycle entries
    for i, start_date in enumerate(sorted_dates):
        cycle_id = str(uuid.uuid4())
        is_last = i == len(sorted_dates) - 1

        # Calculate cycle length if this isn't the last (current) cycle
        end_date = None
        cycle_length = None
        if not is_last:
            next_start = sorted_dates[i + 1]
            end_date = next_start
            cycle_length = (next_start - start_date).days
            cycle_lengths.append(cycle_length)

        cycle_data = {
            "user_id": user_id,
            "start_date": datetime.combine(start_date, datetime.min.time()),
            "end_date": datetime.combine(end_date, datetime.min.time()) if end_date else None,
            "cycle_length": cycle_length,
            "notes": "Initial data from onboarding",
            "created_at": now,
        }

        cycles_ref.document(cycle_id).set(cycle_data)

    # Calculate averages
    avg_cycle_length = calculate_median(cycle_lengths) if cycle_lengths else 28
    last_period_date = datetime.combine(sorted_dates[-1], datetime.min.time())

    # Update user profile
    user_ref.update({
        "average_cycle_length": avg_cycle_length,
        "last_period_start_date": last_period_date,
        "updated_at": now,
    })


async def recalculate_and_update_averages(user_id: str) -> tuple[int, int]:
    """
    Recalculate average cycle and period length from history.

    Uses median for robustness to outliers.

    Args:
        user_id: Firebase user UID

    Returns:
        Tuple of (average_cycle_length, average_period_length)
    """
    cycles = await get_cycle_history(user_id, limit=12)

    # Calculate average cycle length from completed cycles
    completed_cycles = [c for c in cycles if c.cycle_length is not None]
    if completed_cycles:
        cycle_lengths = [c.cycle_length for c in completed_cycles]
        avg_cycle_length = calculate_median(cycle_lengths)
    else:
        avg_cycle_length = 28  # default

    # Use default average period length
    avg_period_length = 5

    # Update user profile
    db = get_firestore_client()
    user_ref = db.collection("users").document(user_id)
    user_ref.update({
        "average_cycle_length": avg_cycle_length,
        "average_period_length": avg_period_length,
        "updated_at": datetime.utcnow(),
    })

    return avg_cycle_length, avg_period_length


async def update_cycle_entry(
    user_id: str,
    cycle_id: str,
    data: UpdateCycleRequest,
) -> Optional[CycleData]:
    """
    Update an existing cycle entry.

    Recalculates affected cycle lengths and averages.

    Args:
        user_id: Firebase user UID
        cycle_id: Cycle document ID
        data: Fields to update

    Returns:
        Updated CycleData or None if not found
    """
    db = get_firestore_client()
    cycle_ref = (
        db.collection("users")
        .document(user_id)
        .collection("cycleData")
        .document(cycle_id)
    )

    # Check if cycle exists
    doc = cycle_ref.get()
    if not doc.exists:
        return None

    # Build update dict
    update_data = {}
    if data.start_date is not None:
        update_data["start_date"] = datetime.combine(data.start_date, datetime.min.time())
    if data.notes is not None:
        update_data["notes"] = data.notes

    if update_data:
        cycle_ref.update(update_data)

    # Recalculate averages
    await recalculate_and_update_averages(user_id)

    # Return updated cycle
    updated_doc = cycle_ref.get()
    if not updated_doc.exists:
        return None

    doc_data = updated_doc.to_dict()
    return CycleData(
        id=cycle_id,
        user_id=user_id,
        start_date=doc_data["start_date"].date() if doc_data.get("start_date") else None,
        end_date=doc_data["end_date"].date() if doc_data.get("end_date") else None,
        cycle_length=doc_data.get("cycle_length"),
        notes=doc_data.get("notes"),
        created_at=doc_data.get("created_at", datetime.utcnow()),
    )


async def delete_cycle_entry(user_id: str, cycle_id: str) -> bool:
    """
    Delete a cycle entry from history.

    Cannot delete if it's the only cycle. Recalculates averages after deletion.

    Args:
        user_id: Firebase user UID
        cycle_id: Cycle document ID

    Returns:
        True if deleted successfully
    """
    db = get_firestore_client()
    cycles_ref = db.collection("users").document(user_id).collection("cycleData")
    cycle_ref = cycles_ref.document(cycle_id)

    # Check if cycle exists
    if not cycle_ref.get().exists:
        raise ValueError("Cycle not found")

    # Count total cycles
    total_cycles = sum(1 for _ in cycles_ref.stream())
    if total_cycles <= 1:
        raise ValueError("Cannot delete the only cycle")

    # Delete the cycle
    cycle_ref.delete()

    # Recalculate averages
    await recalculate_and_update_averages(user_id)

    # Update last_period_start_date if we deleted the most recent cycle
    remaining_cycles = await get_cycle_history(user_id, limit=1)
    if remaining_cycles:
        most_recent = remaining_cycles[0]
        user_ref = db.collection("users").document(user_id)
        user_ref.update({
            "last_period_start_date": datetime.combine(most_recent.start_date, datetime.min.time()),
            "updated_at": datetime.utcnow(),
        })

    return True
