# Period End Tracking with Smart Notifications - Implementation Plan

## Overview

Add optional period end date tracking with smart, non-intrusive notification prompts to improve cycle phase accuracy.

## User Requirements Summary

- **Optional**: Period end dates are not required
- **Smart Prompting**: Prompt day after expected end, wait 2 days if ignored, then stop (max 2 attempts)
- **Notifications**: Use local notifications for prompts
- **UI Access**: "End Period" button in Today view (conditional) + manual entry on calendar
- **Backend**: Calculate actual average period length from historical data (currently hardcoded to 5 days)

## Key Discovery

**Backend already supports period_end_date!**
- `CycleData` model has optional `period_end_date` field
- `UpdateCycleRequest` accepts `period_end_date`
- PATCH `/api/v1/cycle/history/{cycle_id}` endpoint exists
- Only missing: calculation of actual average_period_length (currently hardcoded)

**iOS has NO notification system** - needs to be built from scratch

---

## Implementation Phases

### PHASE 1: Backend Enhancements (3 files)

#### 1.1 Calculate Actual Average Period Length
**File**: `backend/app/services/cycle_service.py`
**Function**: `recalculate_and_update_averages()` (lines 301-335)

**Changes**:
- Replace hardcoded `avg_period_length = 5` (line 324)
- Calculate median from cycles with `period_end_date` set
- Formula: `period_length = period_end_date - start_date`
- Sanity check: only include 2-10 day periods in average
- Fall back to 5 if no valid data

#### 1.2 Add Convenience Endpoint for Current Cycle
**File**: `backend/app/routers/cycle.py`
**New Endpoint**: `POST /api/v1/cycle/end-period`

**Implementation**:
- Accepts `end_date` query parameter
- Finds current open cycle (end_date = None)
- Validates: end_date > start_date, end_date <= today
- Calls existing `update_cycle_entry()` to set period_end_date
- Auto-recalculates averages
- Returns updated CycleInfoResponse

**Benefits**: Simpler than iOS finding the cycle ID manually

---

### PHASE 2: iOS Notification Infrastructure (2 files)

#### 2.1 Create Notification Manager Service
**File**: `StrengthGraceFlow/Services/NotificationManager.swift` (NEW)

**Core Responsibilities**:
- Request/check notification authorization
- Schedule period end notifications (2 attempts)
- Track attempt count per cycle (UserDefaults)
- Cancel notifications when period ended
- Helper: `shouldShowPeriodEndPrompt()` for UI logic

**Notification Schedule**:
- **Notification 1**: (start_date + avg_period_length + 1 day) @ 10 AM
- **Notification 2**: (start_date + avg_period_length + 3 days) @ 10 AM
- Both scheduled together when period is logged
- Cancelled when period is ended

**Attempt Tracking** (local only, not backend):
- Stored in UserDefaults: `periodEndAttempts_{cycleId}`
- Incremented when user ends period or ignores notification
- Max 2 attempts per cycle
- Resets for new cycles

#### 2.2 Add Notification Delegate
**File**: `StrengthGraceFlow/StrengthGraceFlowApp.swift`

**Changes**:
- Make AppDelegate conform to `UNUserNotificationCenterDelegate`
- Set delegate in `didFinishLaunchingWithOptions`
- Handle foreground presentation (show banner)
- Handle notification tap → Post "ShowPeriodEndPrompt" to NotificationCenter

#### 2.3 Integrate with Onboarding
**File**: `StrengthGraceFlow/Features/Onboarding/Views/OnboardingContainerView.swift`

**Changes**:
- Call `NotificationManager.shared.requestAuthorization()` in `completeOnboarding()`
- Request happens after user profile creation
- Non-blocking (doesn't fail onboarding if denied)

---

### PHASE 3: iOS API Layer (1 file)

#### 3.1 Add Period End Method
**File**: `StrengthGraceFlow/Services/APIService.swift`

**New Method**:
```swift
func endCurrentPeriod(endDate: Date) async throws -> CycleInfoResponse {
    // Calls POST /api/v1/cycle/end-period?end_date=YYYY-MM-DD
}
```

**Update Model**:
- Add `periodEndDate` field to `CycleData` struct
- Add to CodingKeys: `period_end_date`

---

### PHASE 4: iOS UI - Today View (2 files)

#### 4.1 Update TodayViewModel
**File**: `StrengthGraceFlow/Features/Today/ViewModels/TodayViewModel.swift`

**New Properties**:
- `@Published var shouldShowEndPeriodButton = false`
- `@Published var currentCycleId: String?`
- `var periodStartDate: Date` (computed from currentCycle)

**Logic Updates in `loadCycleInfo()`**:
- Fetch cycle history to get current cycle ID
- Check if current cycle has `periodEndDate == nil`
- Call `NotificationManager.shouldShowPeriodEndPrompt()` to determine button visibility
- Button shows if:
  - User is menstruating (menstrual phase)
  - No period_end_date set yet
  - Today >= (expectedEndDate + 1 day)
  - Attempt count < 2

**New Method**: `endPeriod(date: Date)`
- Calls `APIService.endCurrentPeriod()`
- Increments attempt count
- Cancels pending notifications
- Hides button

**Update `logPeriod()`**:
- After successful period log, schedule notifications
- `NotificationManager.schedulePeriodEndNotifications(periodStartDate, avgPeriodLength)`

#### 4.2 Update TodayView UI
**File**: `StrengthGraceFlow/Features/Today/Views/TodayView.swift`

**New Components**:
- `EndPeriodButton` - Clickable banner similar to LogPeriodBanner
- `EndPeriodSheet` - Date picker for selecting end date (range: periodStart...today)

**View Changes**:
- Add `@State private var showingEndPeriod = false`
- Conditionally show `EndPeriodButton` if `viewModel.shouldShowEndPeriodButton`
- Present `EndPeriodSheet` on button tap
- Listen for "ShowPeriodEndPrompt" notification (from notification tap)

---

### PHASE 5: iOS UI - Calendar View (1 file)

#### 5.1 Add Period End to Calendar Day Summary
**File**: `StrengthGraceFlow/Features/Cycle/Views/CycleCalendarView.swift`

**Update CycleDaySummarySheet**:
- Add "Mark as Period End Date" button when applicable
- Show if:
  - Date is in menstrual phase
  - Date is not in future
  - Current cycle has no period_end_date
- Button calls viewModel method to end period
- Requires passing viewModel to sheet

---

## Data Flow Diagrams

### Flow 1: Period Start → Notification Scheduling
```
User logs period start
  ↓
TodayViewModel.logPeriod()
  ↓
APIService.logPeriod() → Backend creates cycle
  ↓
NotificationManager.schedulePeriodEndNotifications()
  ↓
Calculate: expectedEnd = start + avgPeriodLength
  ↓
Schedule 2 notifications: +1 day, +3 days @ 10 AM
  ↓
Store dates in UserDefaults
```

### Flow 2: Notification → Period End
```
Notification fires (day after expected end)
  ↓
User taps notification
  ↓
AppDelegate posts "ShowPeriodEndPrompt"
  ↓
TodayView shows EndPeriodSheet
  ↓
User selects end date
  ↓
TodayViewModel.endPeriod()
  ↓
APIService.endCurrentPeriod()
  ↓
Backend updates cycle, recalculates averages
  ↓
NotificationManager.incrementAttemptCount()
NotificationManager.cancelPeriodEndNotifications()
  ↓
Button disappears from UI
```

### Flow 3: Manual Period End (Button)
```
User in Today view during menstrual phase
  ↓
TodayViewModel.loadCycleInfo() checks:
  - Is menstruating? ✓
  - No period_end_date? ✓
  - NotificationManager.shouldShowPeriodEndPrompt()? ✓
  ↓
Show "End Period" button
  ↓
User taps → EndPeriodSheet → Select date → Same as Flow 2
```

---

## Edge Cases & Handling

### 1. User Ends Period Before First Notification
- Notifications cancelled immediately
- Attempt count incremented
- No future prompts for this cycle

### 2. User Ignores Both Notifications
- After 2nd notification, no more prompts
- Button still available if they open app
- Next cycle gets fresh notifications (attempts reset)

### 3. User Logs New Period Without Ending Previous
- Previous cycle closes with `end_date` = new start
- No `period_end_date` set (acceptable - optional field)
- Average calculation only uses cycles with valid period_end_date

### 4. Very Short/Long Periods
- Backend filters outliers: only 2-10 day periods count
- User can still log any value
- Extreme values won't skew average

### 5. Notification Permission Denied
- App works normally, no notifications
- Button logic still works (based on date math)
- User can manually track via calendar

### 6. App Reinstall
- UserDefaults attempt tracking lost (fresh start)
- Backend data persists (period_end_date intact)

---

## Validation Rules

**Backend**:
- `period_end_date >= start_date` (enforced in endpoint)
- `period_end_date <= today` (no future dates)
- Period length 2-10 days for average calculation (outlier filter)

**iOS**:
- Date picker range: `periodStartDate...Date()`
- Notifications only scheduled for future dates
- Max 2 attempts per cycle ID

---

## Implementation Sequence

### Week 1: Backend Foundation
1. Modify `recalculate_and_update_averages()` to calculate actual period lengths
2. Add `/end-period` POST endpoint
3. Test with existing data
4. Deploy to staging

### Week 2: iOS Notifications
5. Create `NotificationManager.swift`
6. Update `AppDelegate` with notification delegate
7. Add permission request to onboarding
8. Test notification authorization flow

### Week 3: iOS API & Data
9. Add `endCurrentPeriod()` to APIService
10. Update `CycleData` model with `periodEndDate`
11. Test API integration

### Week 4: iOS UI
12. Add "End Period" button to TodayView
13. Create `EndPeriodSheet`
14. Update `TodayViewModel` logic
15. Integrate notification scheduling on period log

### Week 5: Polish & Testing
16. Add calendar integration
17. Test all flows (notification, button, calendar)
18. Handle edge cases
19. Final testing and deployment

---

## Critical Files Summary

### Backend (3 files)
1. `backend/app/services/cycle_service.py` - Calculate actual avg period length
2. `backend/app/routers/cycle.py` - Add /end-period endpoint
3. `backend/app/utils/cycle_calculations.py` - Helper functions (optional)

### iOS (6 files)
1. `StrengthGraceFlow/Services/NotificationManager.swift` **(NEW)** - Core notification system
2. `StrengthGraceFlow/StrengthGraceFlowApp.swift` - Notification delegate
3. `StrengthGraceFlow/Services/APIService.swift` - API method + model update
4. `StrengthGraceFlow/Features/Today/ViewModels/TodayViewModel.swift` - Business logic
5. `StrengthGraceFlow/Features/Today/Views/TodayView.swift` - UI components
6. `StrengthGraceFlow/Features/Cycle/Views/CycleCalendarView.swift` - Calendar integration

---

## Testing Strategy

**Backend**:
- Unit test average period length calculation (median, outliers)
- Test /end-period endpoint validation
- Test with incomplete data (some cycles missing period_end_date)

**iOS**:
- Test notification scheduling (use 10-second trigger for testing)
- Test attempt tracking (UserDefaults persistence)
- Test UI button visibility logic (all conditions)
- Test date picker validation

**Integration**:
- Full flow: log period → notification → end period → averages updated
- Test ignored notifications (2 attempts, then stop)
- Test manual period end (cancel notifications)

---

## Success Criteria

- ✅ Backend calculates actual average period length from historical data
- ✅ iOS notification system requests permission during onboarding
- ✅ Notifications scheduled on period start (2 attempts max)
- ✅ "End Period" button appears in Today view at right time
- ✅ User can tap notification or button to mark period end
- ✅ Period end date saved to backend, averages recalculated
- ✅ Notifications cancelled when period ended early
- ✅ No more than 2 prompts per cycle
- ✅ Calendar allows manual period end entry
- ✅ All edge cases handled gracefully

---

## Notes

- Period end dates are **optional** - system works without them
- Missing period_end_date falls back to default (5 days)
- More users log period ends → more accurate phase predictions
- Notification system is non-intrusive (2 attempts max)
- Local attempt tracking (not backend) keeps it simple
- Backend infrastructure already exists, just needs iOS UI
