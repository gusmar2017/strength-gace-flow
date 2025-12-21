"""
Cycle phase calculation utilities.

This module contains the core algorithm for determining the current
menstrual cycle phase based on the last period start date and cycle length.
"""

from datetime import date, timedelta
from typing import Literal, Optional

from app.models.cycle import CycleInfo, CyclePhase, PhasePrediction


def calculate_current_phase(
    last_period_start: date,
    average_cycle_length: int = 28,
    average_period_length: int = 5,
    reference_date: Optional[date] = None,
) -> CycleInfo:
    """
    Calculate the current menstrual cycle phase.

    Phase boundaries (for a typical 28-day cycle):
    - Menstrual: Days 1-5 (bleeding)
    - Follicular: Days 6-13 (pre-ovulation)
    - Ovulatory: Days 14-16 (ovulation window)
    - Luteal: Days 17-28 (post-ovulation)

    Args:
        last_period_start: First day of the most recent period
        average_cycle_length: User's average cycle length (default 28)
        average_period_length: User's average period length (default 5)
        reference_date: Date to calculate for (default: today)

    Returns:
        CycleInfo with current phase and related data
    """
    today = reference_date or date.today()
    days_since_start = (today - last_period_start).days

    # Handle negative days (future period start date)
    if days_since_start < 0:
        days_since_start = 0

    # Calculate cycle day (1-indexed, wraps around)
    cycle_day = (days_since_start % average_cycle_length) + 1

    # Calculate phase boundaries based on cycle length
    # These ratios are based on typical cycle phase distributions
    menstrual_end = average_period_length
    follicular_end = round(average_cycle_length * 0.46)  # ~Day 13 for 28-day
    ovulatory_end = round(average_cycle_length * 0.57)   # ~Day 16 for 28-day

    # Determine current phase
    if cycle_day <= menstrual_end:
        phase = CyclePhase.MENSTRUAL
        days_until_next = menstrual_end - cycle_day + 1
        next_phase = CyclePhase.FOLLICULAR
    elif cycle_day <= follicular_end:
        phase = CyclePhase.FOLLICULAR
        days_until_next = follicular_end - cycle_day + 1
        next_phase = CyclePhase.OVULATORY
    elif cycle_day <= ovulatory_end:
        phase = CyclePhase.OVULATORY
        days_until_next = ovulatory_end - cycle_day + 1
        next_phase = CyclePhase.LUTEAL
    else:
        phase = CyclePhase.LUTEAL
        days_until_next = average_cycle_length - cycle_day + 1
        next_phase = CyclePhase.MENSTRUAL

    # Determine confidence based on data freshness
    # Higher confidence if we have recent period data
    cycles_since_last_log = days_since_start // average_cycle_length
    if cycles_since_last_log == 0:
        confidence: Literal["high", "medium", "low"] = "high"
    elif cycles_since_last_log <= 2:
        confidence = "medium"
    else:
        confidence = "low"

    return CycleInfo(
        current_phase=phase,
        cycle_day=cycle_day,
        days_until_next_phase=days_until_next,
        next_phase=next_phase,
        confidence=confidence,
        phase_display_name=phase.display_name,
        phase_description=phase.description,
        recommended_intensity=phase.recommended_intensity,
    )


def predict_phases(
    last_period_start: date,
    average_cycle_length: int = 28,
    average_period_length: int = 5,
    days_ahead: int = 30,
) -> list[PhasePrediction]:
    """
    Predict cycle phases for upcoming days.

    Args:
        last_period_start: First day of the most recent period
        average_cycle_length: User's average cycle length
        average_period_length: User's average period length
        days_ahead: Number of days to predict

    Returns:
        List of phase predictions
    """
    predictions = []
    today = date.today()

    for i in range(days_ahead):
        target_date = today + timedelta(days=i)
        cycle_info = calculate_current_phase(
            last_period_start=last_period_start,
            average_cycle_length=average_cycle_length,
            average_period_length=average_period_length,
            reference_date=target_date,
        )

        predictions.append(
            PhasePrediction(
                date=target_date,
                predicted_phase=cycle_info.current_phase,
                cycle_day=cycle_info.cycle_day,
            )
        )

    return predictions


def estimate_next_period(
    last_period_start: date,
    average_cycle_length: int = 28,
) -> date:
    """
    Estimate the start date of the next period.

    Args:
        last_period_start: First day of the most recent period
        average_cycle_length: User's average cycle length

    Returns:
        Estimated start date of next period
    """
    today = date.today()
    days_since_start = (today - last_period_start).days

    # Calculate how many complete cycles have passed
    complete_cycles = days_since_start // average_cycle_length

    # Next period starts after the current/next cycle completes
    next_period = last_period_start + timedelta(
        days=average_cycle_length * (complete_cycles + 1)
    )

    # If next period is in the past, add another cycle
    if next_period <= today:
        next_period += timedelta(days=average_cycle_length)

    return next_period
