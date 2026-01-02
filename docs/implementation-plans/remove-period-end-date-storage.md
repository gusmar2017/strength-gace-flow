# Remove Period End Date Storage - Implementation Plan

## Date
2026-01-02

## Context
We previously implemented period end tracking that asked users to provide the end date of their period and stored it in the database. However, this was an unnecessary complexity because:

1. **The end date is implicit**: When a user logs the start of their next period, the previous period's end date is automatically known (the day before the new period starts)
2. **Simpler UX**: Users only need to track one thing - when their period starts
3. **Reduced complexity**: No need for notifications, prompts, or separate UI to mark period end dates

## Changes Made

This implementation plan documents the **removal** of the period end date tracking feature.

### Backend Changes

#### 1. `/backend/app/routers/cycle.py`
**Removed:**
- POST `/api/v1/cycle/end-period` endpoint (lines 75-103)
  - This endpoint allowed users to mark the end date of their current period
  - No longer needed as end dates are now calculated implicitly

#### 2. `/backend/app/services/cycle_service.py`
**Removed:**
- `end_current_period()` function (lines 338-391)
  - Used to mark period end dates and recalculate averages
  - No longer needed

**Reverted:**
- Average period length calculation (lines 323-346)
  - Previously calculated from stored `period_end_date` data using median of historical period lengths
  - Now uses hardcoded default: `avg_period_length = 5`
  - Reason: Without end date storage, we can't calculate actual period length. The 5-day default is reasonable for predictions.

### iOS Changes

#### 3. `NotificationManager.swift` - DELETED
**Removed entire file (184 lines):**
- Period end notification scheduling
- Attempt count tracking via UserDefaults
- Notification delegate methods
- All period-end related notification infrastructure

#### 4. `/iOS/Services/APIService.swift`
**Removed:**
- `endCurrentPeriod(endDate:)` method (lines 127-137)
  - API call to mark period end date
- `periodEndDate` field from `UpdateCycleEntryRequest` (line 269)
- `periodEndDate` field from `CycleData` response model (line 371)

#### 5. `/iOS/Features/Today/ViewModels/TodayViewModel.swift`
**Removed:**
- `shouldShowEndPeriodButton` property (line 17)
- `currentCycleId` property (line 18)
- `periodStartDate` computed property (lines 22-24)
- End period button visibility logic (lines 53-66)
- `isDatePastExpectedEnd()` helper method (lines 68-80)
- Notification scheduling in `logPeriod()` (lines 109-125)
- `endPeriod()` method (lines 133-156)

#### 6. `/iOS/Features/Today/Views/TodayView.swift`
**Removed:**
- `showingEndPeriod` state variable (line 13)
- End Period banner display (lines 29-35)
- End Period sheet presentation (lines 64-66)
- Notification listener for "ShowPeriodEndPrompt" (lines 67-69)
- `EndPeriodBanner` component (lines 160-199)
- `EndPeriodSheet` component (lines 201-259)

#### 7. `/iOS/Features/Cycle/ViewModels/CycleCalendarViewModel.swift`
**Removed:**
- `endPeriod(date:cycleId:)` method (lines 72-90)
  - Called API to mark period end date
  - Managed notification cancellation

#### 8. `/iOS/Features/Cycle/Views/CycleCalendarView.swift`
**Removed:**
- `showingEndPeriodAlert` state variable (line 345)
- `shouldShowEndPeriodButton` computed property (lines 374-391)
- "Mark as Period End Date" button UI (lines 485-507)
- Period end confirmation alert (lines 514-526)

#### 9. `/iOS/StrengthGraceFlowApp.swift`
**Removed:**
- `UNUserNotificationCenterDelegate` conformance from AppDelegate
- UserNotifications import
- Notification delegate setup in `didFinishLaunchingWithOptions`
- `userNotificationCenter(_:willPresent:withCompletionHandler:)` method
- `userNotificationCenter(_:didReceive:withCompletionHandler:)` method
- Period end notification handling logic

### Documentation Changes

#### 10. Deleted Files
- `/docs/implementation-plans/period-end-tracking-with-notifications.md`
- `/docs/testing-guides/period-end-tracking-test-plan.md`

## New Data Model (Simplified)

### Period Tracking
Users only log **period start dates**. When a new period is logged:
1. The new period's `start_date` is recorded
2. The previous cycle's `end_date` is automatically set to the day before the new period's start
3. The previous period's **implicit end date** is calculated as `new_period_start_date - 1 day`

### Example
```
Cycle 1:
- Period starts: Jan 1
- User logs next period on Jan 29
- Cycle 1 automatically gets end_date = Jan 28
- Cycle 1 period_end_date is implicitly Jan 5 (if next period starts Jan 29)

Cycle 2:
- Period starts: Jan 29
- Still open (no end_date yet)
```

## Benefits

1. **Simpler UX**: Users only track one thing - when periods start
2. **Less cognitive load**: No need to remember/track when period ended
3. **Automatic calculations**: Period end is determined by next period start
4. **Reduced code complexity**: No notifications, alerts, or prompts needed
5. **Cleaner data model**: Only store what's necessary

## Migration Notes

- No data migration needed - `period_end_date` field can remain in database schema (will be null/unused)
- Existing data with `period_end_date` values will be ignored
- Users who previously set period end dates won't lose that historical data, but won't be prompted to set it going forward

## Testing Notes

After this change:
- ✅ Users can log period start dates
- ✅ Cycle calculations work with only start dates
- ✅ No period end prompts appear
- ✅ No period end notifications are scheduled
- ✅ Calendar view shows phase predictions based on start dates only
- ✅ Average period length uses default value of 5 days

## Commit Reference

This change reverts commit `717a4e6` - "feat: implement period end tracking with smart notifications"

## Files Modified (Summary)

**Backend (3 files):**
- `backend/app/routers/cycle.py`
- `backend/app/services/cycle_service.py`
- `backend/app/models/cycle.py` (field remains but unused)

**iOS (8 files + 1 deleted):**
- ❌ `StrengthGraceFlow/Services/NotificationManager.swift` (DELETED)
- `StrengthGraceFlow/Services/APIService.swift`
- `StrengthGraceFlow/StrengthGraceFlowApp.swift`
- `StrengthGraceFlow/Features/Today/ViewModels/TodayViewModel.swift`
- `StrengthGraceFlow/Features/Today/Views/TodayView.swift`
- `StrengthGraceFlow/Features/Cycle/ViewModels/CycleCalendarViewModel.swift`
- `StrengthGraceFlow/Features/Cycle/Views/CycleCalendarView.swift`

**Total changes:** ~1195 lines removed/reverted across 11 files

---

**Implementation Status:** ✅ Complete (2026-01-02)
