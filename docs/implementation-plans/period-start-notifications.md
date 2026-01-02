# Period Start Notifications - Implementation Plan

## Date
2026-01-02

## Context

After removing the period end tracking feature, we implemented a simpler, more user-friendly notification system that prompts users to log their period **start date** when it's likely their next period has begun.

### Design Goals

1. **Simplified UX**: Users only track one thing - when their period starts
2. **Smart reminders**: Notifications sent based on predicted period start (using average cycle length)
3. **Brand-aligned**: Warm, supportive tone that feels like a caring check-in
4. **Non-intrusive**: 2 attempts max, easy to dismiss, optional dialog

## Notification Schedule

### Timing Strategy
- **Attempt 1**: Day AFTER predicted period start (+1 day from prediction)
- **Attempt 2**: 3 days after predicted start (+3 days from prediction)
- **Time**: 9:00 AM (morning check-in)

### Rationale
- Wait until day after predicted start to avoid false alarms (cycles vary naturally)
- Second attempt 2 days later gives user time while still being helpful
- Morning notifications are less intrusive than evening

## Notification Content

### Attempt 1
```
Title: "Checking in 💜"
Body: "Has your period started? Tap to log and stay in sync with your cycle."
```

### Attempt 2
```
Title: "Period tracking check-in"
Body: "Just checking - time to log your period? Staying consistent helps us support you better."
```

### Brand Voice Characteristics
- Warm and supportive (not clinical)
- Uses "checking in" language (caring friend, not reminder bot)
- Emphasizes benefits ("stay in sync", "support you better")
- Includes purple heart emoji (brand color)
- Non-judgmental tone ("just checking")

## User Flow

### Happy Path
1. User logs period on Day 1
2. System calculates: Next expected period = Day 1 + avg cycle length
3. System schedules:
   - Notification 1: (Expected date + 1 day) at 9 AM
   - Notification 2: (Expected date + 3 days) at 9 AM
4. User receives notification on predicted date + 1 day
5. User taps notification
6. Dialog appears: "Has your period started?"
7. User taps "Yes, Log Period"
8. Log period sheet opens
9. User logs period start date
10. Both pending notifications are cancelled
11. New notifications scheduled based on new period date

### Alternative Paths

**User dismisses notification:**
- Notification cleared
- Second notification still scheduled
- No penalties or persistent reminders

**User says "Not Yet" in dialog:**
- Dialog closes
- Second notification still scheduled
- User can manually log when ready

**User logs period before notification:**
- When period is logged, any pending notifications are cancelled
- New notifications scheduled for next cycle

## Technical Implementation

### Files Created

#### 1. `NotificationManager.swift` (NEW)
**Location:** `/iOS/Services/NotificationManager.swift`

**Key Methods:**
- `requestAuthorization() async -> Bool` - Request notification permissions
- `schedulePeriodStartNotifications(periodStartDate:avgCycleLength:cycleId:)` - Schedule both notifications
- `scheduleNotification(date:attemptNumber:cycleId:)` - Schedule individual notification
- `cancelPeriodStartNotifications()` - Cancel all pending notifications
- `shouldShowPeriodStartPrompt(lastPeriodStart:avgCycleLength:) -> Bool` - Check if in-app prompt should show

**Notification Identifiers:**
- `period_start_attempt_1`
- `period_start_attempt_2`

**Notification Metadata:**
```swift
userInfo = [
    "type": "period_start",
    "cycleId": cycleId,
    "attemptNumber": attemptNumber
]
```

### Files Modified

#### 2. `StrengthGraceFlowApp.swift`
**Changes:**
- Added `UNUserNotificationCenterDelegate` conformance to AppDelegate
- Restored `UserNotifications` import
- Set notification delegate in `didFinishLaunchingWithOptions`
- Implemented `userNotificationCenter(_:willPresent:)` - Shows notifications in foreground
- Implemented `userNotificationCenter(_:didReceive:)` - Handles notification taps
- Posts `"ShowPeriodStartDialog"` notification when period start notification tapped

#### 3. `TodayViewModel.swift`
**Changes in `logPeriod()` method:**
- After successful period log, fetch cycle history to get cycle ID
- Call `NotificationManager.shared.schedulePeriodStartNotifications()`
- Pass: period start date, average cycle length, cycle ID
- Wrapped in do-catch to make notification scheduling non-critical

#### 4. `CycleCalendarViewModel.swift`
**Changes in `logCycleStart()` method:**
- Same notification scheduling logic as TodayViewModel
- After successful period log, schedule notifications
- Ensures notifications work from calendar view as well

#### 5. `TodayView.swift`
**Added:**
- `@State private var showingPeriodStartDialog = false` - Controls alert visibility
- `.alert("Period Check-In 💜")` - Dialog asking if period started
  - "Not Yet" button (cancel role)
  - "Yes, Log Period" button (opens log period sheet)
- `.onReceive()` listener for `"ShowPeriodStartDialog"` notification
  - Sets `showingPeriodStartDialog = true` when notification tapped

## Cancellation Logic

Notifications are cancelled when:

1. **User logs a new period**
   - `logPeriod()` and `logCycleStart()` call `schedulePeriodStartNotifications()`
   - This method first calls `cancelPeriodStartNotifications()`
   - All pending period start notifications removed
   - New notifications scheduled based on new period date

2. **All attempts exhausted**
   - After Attempt 2 fires, no more notifications scheduled
   - No persistent reminders beyond 2 attempts

3. **User never installed/denied notifications**
   - App works normally without notifications
   - In-app log period banner still shows
   - No errors or degraded experience

## Permission Handling

### Request Timing
- Notification permission requested during onboarding (already implemented)
- If user denies, app continues to work normally
- Users can enable notifications later in iOS Settings

### Permission States

**Authorized:**
- Notifications scheduled as designed
- User receives period start reminders

**Denied:**
- Notification scheduling calls succeed silently (no errors)
- No notifications delivered
- In-app prompts still work (log period banner)

**Not Determined:**
- Will request authorization during onboarding
- If user hasn't onboarded yet, no notifications scheduled

## Data Flow

### When Period is Logged

```
User logs period (date: Jan 1)
    ↓
API call: POST /api/v1/cycle/log-period
    ↓
Backend creates cycle, returns cycle info (avgCycleLength: 28)
    ↓
Frontend fetches cycle history to get cycle ID
    ↓
Calculate predicted next period: Jan 1 + 28 days = Jan 29
    ↓
Schedule Notification 1: Jan 30 (predicted + 1) at 9 AM
Schedule Notification 2: Feb 1 (predicted + 3) at 9 AM
    ↓
Notifications pending in UNUserNotificationCenter
```

### When Notification Fires

```
Jan 30, 9:00 AM - iOS delivers notification
    ↓
User taps notification
    ↓
AppDelegate.userNotificationCenter(_:didReceive:) called
    ↓
Checks userInfo["type"] == "period_start"
    ↓
Posts NotificationCenter notification: "ShowPeriodStartDialog"
    ↓
TodayView.onReceive() catches notification
    ↓
Sets showingPeriodStartDialog = true
    ↓
Alert appears: "Has your period started?"
    ↓
User taps "Yes, Log Period"
    ↓
Sets showingLogPeriod = true
    ↓
LogPeriodSheet appears
    ↓
User logs period
    ↓
Pending notifications cancelled, new ones scheduled
```

## Edge Cases Handled

### 1. User logs period multiple times in quick succession
**Behavior:** Each log cancels pending notifications and schedules new ones
**Result:** Only most recent notifications remain

### 2. Average cycle length changes
**Behavior:** Each period log uses current average cycle length for scheduling
**Result:** Predictions improve over time as more data collected

### 3. Very irregular cycles (high variance)
**Behavior:** Notifications still scheduled based on average
**Result:** User may receive notifications too early or late, but can dismiss/ignore

### 4. User changes phone time zone
**Behavior:** Notifications use calendar components (year/month/day/hour), not absolute time
**Result:** 9 AM in user's current time zone

### 5. User logs period before notifications fire
**Behavior:** Pending notifications cancelled when new period logged
**Result:** No unnecessary notifications

### 6. App uninstalled then reinstalled
**Behavior:** Notifications cleared when app uninstalled
**Result:** User needs to log new period to receive notifications again

## Testing Scenarios

### Manual Testing

**Test 1: Basic Flow**
1. Log period on Day 1
2. Verify 2 notifications scheduled (check iOS Settings > Notifications)
3. Wait for notification or use iOS Simulator time simulation
4. Tap notification
5. Verify dialog appears asking if period started
6. Tap "Yes, Log Period"
7. Verify log period sheet opens

**Test 2: Cancellation**
1. Log period on Day 1
2. Verify notifications scheduled
3. Log another period before notifications fire
4. Verify old notifications cancelled (check pending notifications)
5. Verify new notifications scheduled

**Test 3: Dismissal**
1. Receive notification
2. Tap "Not Yet" in dialog
3. Verify dialog closes
4. Verify second notification still pending

**Test 4: No Permission**
1. Deny notification permission
2. Log period
3. Verify no errors
4. Verify app works normally
5. Verify in-app banner still prompts period logging

### Automated Testing (Future)
- Mock UNUserNotificationCenter for unit tests
- Test notification scheduling calculation logic
- Test cancellation logic
- Test permission handling

## Future Enhancements (Not Implemented)

1. **User-configurable notification time**
   - Allow user to set preferred notification time (currently hardcoded 9 AM)

2. **Smart scheduling based on cycle regularity**
   - For very regular cycles (low variance): notify on predicted date
   - For irregular cycles (high variance): notify +2 days after predicted

3. **Notification preferences**
   - Let user enable/disable period start notifications
   - Let user choose number of attempts (1, 2, or 3)

4. **Rich notifications**
   - Include quick actions: "Log Now" vs "Remind Me Tomorrow"
   - Avoid needing to open app

5. **Analytics**
   - Track notification delivery rate
   - Track tap-through rate
   - Track conversion (notification → period logged)

## Success Metrics

**User Engagement:**
- % of users who enable notifications
- % of users who respond to notifications (tap or log period)
- Average time between notification and period log

**Data Quality:**
- % of periods logged within 3 days of actual start
- Reduction in "forgotten" period logs (backdated entries)

**User Satisfaction:**
- User feedback on notification timing and tone
- User retention (do notifications help or annoy?)

## Files Summary

**Created (1 file):**
- `/iOS/Services/NotificationManager.swift` (NEW - 185 lines)

**Modified (4 files):**
- `/iOS/StrengthGraceFlowApp.swift` - Notification delegate setup
- `/iOS/Features/Today/ViewModels/TodayViewModel.swift` - Scheduling logic
- `/iOS/Features/Cycle/ViewModels/CycleCalendarViewModel.swift` - Scheduling logic
- `/iOS/Features/Today/Views/TodayView.swift` - Dialog UI

**Total changes:** ~250 lines added across 5 files

---

**Implementation Status:** ✅ Complete (2026-01-02)
