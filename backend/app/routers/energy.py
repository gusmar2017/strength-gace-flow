"""
Energy tracking API endpoints.
"""

from datetime import date

from fastapi import APIRouter, HTTPException, Query, status

from app.middleware.auth import CurrentUser
from app.models.energy import (
    EnergyHistoryResponse,
    EnergyLogResponse,
    LogEnergyRequest,
)
from app.services import energy_service

router = APIRouter(prefix="/api/v1/energy", tags=["Energy Tracking"])


@router.post("/log", response_model=EnergyLogResponse)
async def log_energy(
    user: CurrentUser,
    data: LogEnergyRequest,
):
    """
    Log daily energy level.

    Allows users to rate their energy from 1-10 for a specific day.
    If an entry already exists for the date, it will be updated.
    """
    energy_log = await energy_service.log_energy(user.uid, data)

    return EnergyLogResponse(energy=energy_log)


@router.get("/today", response_model=EnergyLogResponse)
async def get_today_energy(user: CurrentUser):
    """
    Get today's energy level if it has been logged.

    Returns 404 if no entry exists for today.
    """
    today = date.today()
    energy_log = await energy_service.get_energy_for_date(user.uid, today)

    if energy_log is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No energy logged for today",
        )

    return EnergyLogResponse(energy=energy_log)


@router.get("/history", response_model=EnergyHistoryResponse)
async def get_energy_history(
    user: CurrentUser,
    days: int = Query(default=30, ge=7, le=90),
):
    """
    Get energy level history for the past N days.

    Returns energy logs sorted by date descending.
    """
    entries = await energy_service.get_energy_history(user.uid, days=days)

    # Calculate average from all entries
    if entries:
        avg_score = sum(e.score for e in entries) / len(entries)
    else:
        avg_score = 0.0

    return EnergyHistoryResponse(
        entries=entries,
        average_score=round(avg_score, 1),
        total_logs=len(entries),
    )


@router.delete("/{log_id}", status_code=status.HTTP_200_OK)
async def delete_energy_log(
    user: CurrentUser,
    log_id: str,
):
    """
    Delete an energy log entry.

    Returns 404 if the log doesn't exist or doesn't belong to the user.
    """
    success = await energy_service.delete_energy_log(user.uid, log_id)

    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Energy log not found",
        )

    return {"message": "Energy log deleted successfully"}
