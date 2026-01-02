"""
Cycle tracking API endpoints.
"""

from datetime import date

from fastapi import APIRouter, HTTPException, Query, status

from app.middleware.auth import CurrentUser
from app.models.cycle import (
    CycleData,
    CycleHistoryResponse,
    CycleInfoResponse,
    CyclePredictionsResponse,
    LogPeriodRequest,
    UpdateCycleRequest,
)
from app.services import cycle_service

router = APIRouter(prefix="/api/v1/cycle", tags=["Cycle Tracking"])


@router.get("/current", response_model=CycleInfoResponse)
async def get_current_cycle(user: CurrentUser):
    """
    Get current cycle phase information.

    Returns the user's current menstrual cycle phase, cycle day,
    days until next phase, and phase-specific guidance.

    Returns 404 if no period has been logged yet.
    """
    cycle_info = await cycle_service.get_current_cycle_info(user.uid)

    if cycle_info is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No cycle data found. Please log your first period to get started.",
        )

    return cycle_info


@router.post("/log-period", response_model=CycleInfoResponse)
async def log_period_start(
    user: CurrentUser,
    data: LogPeriodRequest,
):
    """
    Log the start of a new period.

    This updates the cycle tracking and recalculates the current phase.
    If a previous cycle was open, it will be closed with the calculated length.
    """
    try:
        await cycle_service.log_period(user.uid, data)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )

    # Return updated cycle info
    cycle_info = await cycle_service.get_current_cycle_info(user.uid)

    if cycle_info is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to calculate cycle info after logging period.",
        )

    return cycle_info


@router.get("/history", response_model=CycleHistoryResponse)
async def get_cycle_history(
    user: CurrentUser,
    limit: int = Query(default=12, ge=1, le=24),
):
    """
    Get cycle history for the user.

    Returns past cycles with start dates, lengths, and notes.
    Limited to the most recent cycles (default 12, max 24).
    """
    cycles = await cycle_service.get_cycle_history(user.uid, limit=limit)

    # Calculate average from completed cycles
    completed_cycles = [c for c in cycles if c.cycle_length is not None]
    if completed_cycles:
        avg_length = sum(c.cycle_length for c in completed_cycles) // len(completed_cycles)
    else:
        avg_length = 28  # Default

    return CycleHistoryResponse(
        cycles=cycles,
        average_cycle_length=avg_length,
        total_cycles_logged=len(cycles),
    )


@router.get("/predictions", response_model=CyclePredictionsResponse)
async def get_cycle_predictions(
    user: CurrentUser,
    days: int = Query(default=30, ge=7, le=90),
):
    """
    Get predicted cycle phases for upcoming days.

    Predicts the menstrual cycle phase for each day based on
    the user's average cycle length and last period date.

    Returns 404 if no period has been logged yet.
    """
    predictions, next_period = await cycle_service.get_cycle_predictions(
        user.uid,
        days_ahead=days,
    )

    if not predictions:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No cycle data found. Please log your first period to get predictions.",
        )

    return CyclePredictionsResponse(
        predictions=predictions,
        next_period_start=next_period,
    )


@router.patch("/history/{cycle_id}", response_model=CycleData)
async def update_cycle_entry(
    user: CurrentUser,
    cycle_id: str,
    data: UpdateCycleRequest,
):
    """
    Update a cycle entry (change start date, add period end date, edit notes).

    Automatically recalculates averages after update.
    """
    updated_cycle = await cycle_service.update_cycle_entry(user.uid, cycle_id, data)

    if updated_cycle is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cycle entry not found",
        )

    return updated_cycle


@router.delete("/history/{cycle_id}", status_code=status.HTTP_200_OK)
async def delete_cycle_entry(
    user: CurrentUser,
    cycle_id: str,
):
    """
    Delete a cycle entry from history.

    Cannot delete if it's the only cycle. Recalculates averages after deletion.
    """
    try:
        await cycle_service.delete_cycle_entry(user.uid, cycle_id)
        return {"message": "Cycle deleted successfully"}
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
