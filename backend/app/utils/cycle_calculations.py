"""
Cycle phase calculation utilities.

This module contains the core algorithm for determining the current
menstrual cycle phase based on the last period start date and cycle length.
"""

from datetime import date, timedelta
from typing import Literal, Optional
import statistics

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
    earliest_cycle_date: Optional[date] = None,
) -> list[PhasePrediction]:
    """
    Predict cycle phases for upcoming days and full historical cycles.

    Generates predictions for:
    - All historical cycles from earliest logged cycle (or 90 days back as fallback)
    - Future days up to 3 days after next predicted period start

    Args:
        last_period_start: First day of the most recent period
        average_cycle_length: User's average cycle length
        average_period_length: User's average period length
        days_ahead: Number of days to predict forward (will be capped at next period + 3 days)
        earliest_cycle_date: Earliest logged cycle date (for full history)

    Returns:
        List of phase predictions including full historical and future dates
    """
    predictions = []
    today = date.today()

    # Calculate next period start date
    next_period_start = estimate_next_period(
        last_period_start=last_period_start,
        average_cycle_length=average_cycle_length,
    )

    # Limit future predictions to 3 days after next period start
    # This prevents showing too many future cycles on the calendar
    max_prediction_date = next_period_start + timedelta(days=3)
    max_future_days = (max_prediction_date - today).days
    effective_future_days = min(days_ahead, max_future_days)

    # Determine start date for historical predictions
    if earliest_cycle_date:
        # Use actual earliest cycle date for full history
        start_date = earliest_cycle_date
    else:
        # Fallback: 90 days back if no cycle history available
        start_date = today - timedelta(days=90)

    # Generate predictions from earliest date to future
    total_days = (today - start_date).days + effective_future_days
    for i in range(total_days):
        target_date = start_date + timedelta(days=i)
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


def calculate_median(values: list[int]) -> int:
    """
    Calculate the median of a list of integers.

    Median is more robust to outliers than mean for cycle length calculations.
    For example: [27, 28, 28, 45, 28] -> median=28, mean=31.2

    Args:
        values: List of integer values

    Returns:
        Median value as an integer
    """
    if not values:
        return 28  # default

    return round(statistics.median(values))


def calculate_confidence_from_history(
    cycles_count: int,
    cycle_lengths: list[int],
    days_since_last_log: int,
) -> Literal["high", "medium", "low"]:
    """
    Calculate confidence level based on historical data quality.

    Args:
        cycles_count: Number of complete cycles logged
        cycle_lengths: List of cycle lengths in days
        days_since_last_log: Days since last period was logged

    Returns:
        Confidence level: "high", "medium", or "low"

    Confidence criteria:
        High: 3+ cycles, consistent lengths (stdev < 3 days), recent data (< 35 days)
        Medium: 2+ cycles OR recent data (< 70 days)
        Low: 1 cycle OR old data OR irregular cycles
    """
    # Insufficient data
    if cycles_count < 1:
        return "low"

    # Calculate variability if we have multiple cycles
    is_consistent = True
    if len(cycle_lengths) >= 2:
        std_dev = statistics.stdev(cycle_lengths)
        is_consistent = std_dev < 3

    # Calculate average cycle for recency check
    avg_cycle = calculate_median(cycle_lengths) if cycle_lengths else 28

    # High confidence: good data volume, consistency, and recency
    if cycles_count >= 3 and is_consistent and days_since_last_log < avg_cycle * 1.2:
        return "high"

    # Medium confidence: decent data or recent
    if cycles_count >= 2 or days_since_last_log < avg_cycle * 2.5:
        return "medium"

    # Low confidence: sparse or old data
    return "low"
