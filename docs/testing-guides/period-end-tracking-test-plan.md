# Period End Tracking - Testing Guide

## Prerequisites
- Backend running locally or deployed
- iOS app installed on simulator or device
- Fresh user account recommended for testing (or existing account with cycle data)

---

## Test 1: Notification Permission Request (Onboarding)

### Steps:
1. **Delete app** from simulator/device (to reset onboarding state)
2. **Reinstall and launch** the app
3. **Complete onboarding flow**:
   - Enter name
   - Select avatar
   - Choose cycle tracking preference
   - Enter last period start date
   - Complete setup

### Expected Results:
✅ System notification permission dialog appears after completing onboarding
✅ Tap "Allow" - notification permission granted
✅ App continues normally regardless of permission choice
✅ If "Don't Allow" is tapped, app still works (feature degrades gracefully)

### Verify:
- iOS Settings → Notifications → StrengthGraceFlow shows correct permission status

---

## Test 2: Notification Scheduling (After Logging Period)

### Steps:
1. **Navigate to Today view**
2. **Log a new period** (tap "+" button or "Log Period" banner)
3. **Select today's date** and confirm

### Expected Results:
✅ Period logged successfully
✅ Today view updates to show menstrual phase
✅ Notifications scheduled in background (not visible to user yet)

### Verify Notifications Were Scheduled:
**Option A - Quick Test (Immediate Trigger)**:
1. Temporarily modify `NotificationManager.swift` to schedule notifications sooner:
   ```swift
   // Change from:
   var trigger1 = DateComponents(hour: 10, minute: 0, second: 0)
   // To:
   var trigger1 = TimeInterval(10) // 10 seconds from now
   ```

**Option B - Normal Flow (Wait for Real Time)**:
- Wait until (period_start + avg_period_length + 1 day) @ 10:00 AM
- Default avg_period_length = 5 days if no historical data
- So notifications should fire 6 days after period start

---

## Test 3: End Period Button Visibility (Today View)

### Steps:
1. **Log a period** (if not already done)
2. **Wait or simulate** until day 6 (period_start + 5 days + 1 day)
3. **Open Today view**

### Expected Results:
✅ Blue "End Period" banner appears with text: "Has your period ended? Tap to log your period end date"
✅ Banner positioned below phase card
✅ Banner only shows if:
   - User is in menstrual phase
   - No period_end_date set yet
   - Today >= (expected_end + 1 day)
   - Attempt count < 2

### Test Edge Cases:
- **Before day 6**: Banner should NOT appear
- **After ending period**: Banner should disappear
- **After 2 attempts**: Banner should disappear

---

## Test 4: End Period Flow (Today View)

### Steps:
1. **Tap the blue "End Period" banner**
2. **Sheet appears** with date picker
3. **Select a date** (between period start and today)
4. **Tap "Save"**

### Expected Results:
✅ Sheet has title "When did your period end?"
✅ Date picker defaults to today
✅ Date range constrained: periodStartDate...today
✅ Cannot select dates before period start
✅ Cannot select future dates
✅ After tapping "Save":
   - Sheet dismisses
   - Banner disappears
   - Backend updated with period_end_date
   - Attempt count incremented to 1
   - Pending notifications cancelled

### Verify Backend:
Check that period_end_date was saved:
```bash
# In backend logs or database
# The cycle should now have period_end_date set
```

---

## Test 5: Period End from Notification Tap

### Steps:
1. **Log a period**
2. **Wait for notification** to fire (or use 10-second test trigger)
3. **Tap the notification**

### Expected Results:
✅ Notification appears with:
   - Title: "Period End Check"
   - Body: "Has your period ended? Tap to log the end date."
✅ Tapping notification opens app to Today view
✅ End Period sheet automatically opens
✅ Same flow as Test 4 (select date, save, updates backend)

### Test Foreground Behavior:
- If app is already open when notification fires:
  - ✅ Banner notification still appears at top
  - ✅ Sound plays
  - ✅ Tapping banner opens End Period sheet

---

## Test 6: Calendar Manual Period End Entry

### Steps:
1. **Log a period** (if not already done)
2. **Navigate to Cycle Calendar view** (bottom tab)
3. **Tap on a date** during the menstrual phase (period start + 1-5 days)
4. **Day summary sheet opens**
5. **Look for "Mark as Period End Date" button**

### Expected Results:
✅ Button appears if:
   - Date is in menstrual phase
   - Date is not in the future
   - Current cycle has no period_end_date set
✅ Button is styled with primary/blue color
✅ Button positioned at bottom of sheet

### Complete the Flow:
1. **Tap "Mark as Period End Date"**
2. **Confirmation alert appears**: "Are you sure you want to mark [date] as your period end date?"
3. **Tap "Confirm"**

### Expected Results:
✅ Sheet dismisses
✅ Backend updated with period_end_date
✅ Notifications cancelled
✅ Attempt count incremented
✅ If you tap the same date again, button should no longer appear

---

## Test 7: Attempt Tracking (Max 2 Attempts)

### Steps:
1. **Log a period**
2. **End the period** via banner or notification (Attempt 1)
3. **Reload cycle info** (pull to refresh or restart app)
4. **Check if banner appears again**

### Expected Results After Attempt 1:
✅ Banner should still appear (attempt count = 1, max = 2)
✅ User can end period again if needed

### Complete Attempt 2:
1. **Tap banner again** and select a different date (or same)
2. **Save**

### Expected Results After Attempt 2:
✅ Banner disappears permanently for this cycle
✅ Even if app is restarted, banner doesn't show again
✅ Attempt count = 2 (stored in UserDefaults: `periodEndAttempts_{cycleId}`)

### Verify UserDefaults:
```swift
// Check in Xcode debugger or add temporary logging:
print(UserDefaults.standard.integer(forKey: "periodEndAttempts_{cycleId}"))
// Should print: 2
```

---

## Test 8: Notification Cancellation (Early Period End)

### Steps:
1. **Log a period**
2. **Immediately end the period** via banner (before first notification fires)

### Expected Results:
✅ Period ended successfully
✅ Notifications cancelled in background
✅ No notifications should fire later (day 6 or day 8)

### Verify:
- Wait until the original notification time (day 6 @ 10 AM)
- ✅ No notification appears

---

## Test 9: Ignoring Notifications (2 Attempts, Then Stop)

### Steps:
1. **Log a period**
2. **Wait for first notification** (day 6 @ 10 AM)
3. **Ignore it** (don't tap)
4. **Wait for second notification** (day 8 @ 10 AM)
5. **Ignore it** (don't tap)

### Expected Results:
✅ First notification appears, then disappears if not tapped
✅ Second notification appears 2 days later
✅ No third notification fires
✅ Banner still available in app if user opens it

---

## Test 10: New Period Without Ending Previous

### Steps:
1. **Log a period** (Period A)
2. **Do NOT end it**
3. **Wait several weeks**
4. **Log a new period** (Period B)

### Expected Results:
✅ Previous cycle (Period A) closes automatically:
   - `end_date` set to new period start date
   - `period_end_date` remains `null` (optional field)
✅ New cycle (Period B) created successfully
✅ New notifications scheduled for Period B
✅ Attempt count resets to 0 for new cycle

### Verify Average Calculation:
- Since Period A has no `period_end_date`, it won't be used in average calculation
- Average still falls back to 5 days (or uses other cycles with valid data)

---

## Test 11: Backend Average Period Length Calculation

### Setup:
Create multiple cycles with period end dates to test average calculation.

### Steps:
1. **Log Period 1**: Start 2025-01-01, End 2025-01-05 (4 days)
2. **Log Period 2**: Start 2025-02-01, End 2025-02-06 (5 days)
3. **Log Period 3**: Start 2025-03-01, End 2025-03-06 (5 days)
4. **Check cycle info** API response

### Expected Results:
✅ `average_period_length` = 5 (median of [4, 5, 5])
✅ Backend uses median, not mean (more robust to outliers)

### Test Outlier Filtering:
1. **Log Period 4**: Start 2025-04-01, End 2025-04-15 (14 days - outlier)

### Expected Results:
✅ Period 4 is excluded from average (> 10 days)
✅ `average_period_length` still = 5 (only uses [4, 5, 5])

### Test Short Period Outlier:
1. **Log Period 5**: Start 2025-05-01, End 2025-05-02 (1 day - outlier)

### Expected Results:
✅ Period 5 excluded from average (< 2 days)
✅ `average_period_length` still = 5

### Test No Valid Data:
1. **Delete all period_end_dates** from backend
2. **Reload cycle info**

### Expected Results:
✅ `average_period_length` = 5 (default fallback)

---

## Test 12: Backend /end-period Endpoint

### Test Successful Request:
```bash
# Get auth token first
TOKEN="your_firebase_token"

# End current period
curl -X POST "http://localhost:8000/api/v1/cycle/end-period?end_date=2026-01-05" \
  -H "Authorization: Bearer $TOKEN"
```

### Expected Response:
```json
{
  "current_cycle": {
    "cycle_day": 5,
    "phase": "menstrual",
    "days_until_next_period": 23,
    "is_menstruating": true
  },
  "average_cycle_length": 28,
  "average_period_length": 5,
  "predicted_next_period_date": "2026-02-02"
}
```

### Test Error Cases:

**No Open Cycle:**
```bash
# When no cycle has end_date = None
curl -X POST "http://localhost:8000/api/v1/cycle/end-period?end_date=2026-01-05" \
  -H "Authorization: Bearer $TOKEN"
```
Expected: `404 Not Found` - "No open cycle found"

**Future Date:**
```bash
curl -X POST "http://localhost:8000/api/v1/cycle/end-period?end_date=2030-01-01" \
  -H "Authorization: Bearer $TOKEN"
```
Expected: `400 Bad Request` - "Period end date cannot be in the future"

**End Date Before Start:**
```bash
# If period started 2026-01-05, try to end it 2026-01-01
curl -X POST "http://localhost:8000/api/v1/cycle/end-period?end_date=2026-01-01" \
  -H "Authorization: Bearer $TOKEN"
```
Expected: `400 Bad Request` - "Period end date must be after start date"

---

## Test 13: Edge Case - Notification Permission Denied

### Steps:
1. **During onboarding**, tap "Don't Allow" for notifications
2. **Complete onboarding**
3. **Log a period**
4. **Navigate to Today view**

### Expected Results:
✅ App works normally
✅ No notifications fire (obviously, since denied)
✅ Banner logic still works (based on date math)
✅ User can still manually end period via banner or calendar

### Re-enable Notifications:
1. **Go to iOS Settings** → Notifications → StrengthGraceFlow
2. **Enable notifications**
3. **Restart app**
4. **Log a new period**

### Expected Results:
✅ Notifications now schedule and fire correctly

---

## Test 14: Edge Case - App Reinstall

### Steps:
1. **Log periods with end dates**
2. **Note the attempt count** for current cycle
3. **Delete app**
4. **Reinstall app**
5. **Log in with same account**

### Expected Results:
✅ Backend data persists (all period_end_dates intact)
✅ UserDefaults attempt tracking lost (reset to 0)
✅ User gets fresh 2 attempts for existing cycle
✅ Notifications must be rescheduled (local notifications cleared on uninstall)

---

## Test 15: UI/UX Polish Checks

### Today View:
✅ End Period banner has consistent styling with Log Period banner
✅ Banner appears in correct position (below phase card)
✅ Sheet has proper title, spacing, and button styling
✅ Date picker is easy to use and properly constrained
✅ Loading states handled (no UI freezes)

### Calendar View:
✅ "Mark as Period End Date" button clearly visible
✅ Confirmation alert prevents accidental taps
✅ Button disappears after period end is set
✅ Calendar updates to reflect period end (if applicable to UI)

### Notifications:
✅ Notification text is clear and actionable
✅ Notifications appear at correct time (10 AM)
✅ Tapping notification opens app smoothly
✅ Foreground notifications show banner (not just silent)

---

## Summary Checklist

### Backend:
- [ ] Average period length calculated from historical data
- [ ] Outliers (< 2 days, > 10 days) filtered out
- [ ] Falls back to 5 days when no valid data
- [ ] /end-period endpoint works correctly
- [ ] Validation prevents invalid dates
- [ ] Averages recalculated after period end

### iOS Notifications:
- [ ] Permission requested during onboarding
- [ ] Notifications scheduled on period log
- [ ] First notification fires at expected time
- [ ] Second notification fires 2 days later
- [ ] No third notification fires
- [ ] Notifications cancelled when period ended early
- [ ] Tapping notification opens End Period sheet

### iOS Today View:
- [ ] End Period banner appears at correct time
- [ ] Banner respects attempt count (max 2)
- [ ] Sheet has proper date constraints
- [ ] Ending period updates backend
- [ ] Banner disappears after 2 attempts
- [ ] Notifications cancelled when period ended

### iOS Calendar View:
- [ ] Button appears on menstrual phase dates
- [ ] Button doesn't appear after period ended
- [ ] Confirmation alert works
- [ ] Marking period end updates backend
- [ ] Button disappears after setting end date

### Edge Cases:
- [ ] Works without notification permission
- [ ] Handles new period without ending previous
- [ ] Attempt tracking persists across app restarts
- [ ] Data persists across app reinstalls (backend)
- [ ] UserDefaults resets on reinstall (expected behavior)

---

## Quick Test Script (Minimal Testing)

If you want to quickly verify everything works:

1. **Fresh start**: Delete app, reinstall
2. **Complete onboarding**: Allow notifications
3. **Log a period**: Use today's date
4. **Modify NotificationManager**: Change triggers to 10 seconds for testing
5. **Wait 10 seconds**: Notification should appear
6. **Tap notification**: Sheet opens
7. **Select date and save**: Backend updates
8. **Check calendar**: Tap a menstrual date, button appears
9. **Mark period end**: Confirmation alert, then saves
10. **Verify**: Banner no longer appears after 2 attempts

---

## Debugging Tips

### Check Notification Permissions:
```swift
// Add to NotificationManager for debugging
let status = await checkAuthorizationStatus()
print("Notification authorization status: \(status)")
```

### Check Attempt Count:
```swift
// Add to TodayViewModel
print("Attempt count for cycle \(cycleId): \(UserDefaults.standard.integer(forKey: "periodEndAttempts_\(cycleId)"))")
```

### Check Scheduled Notifications:
```swift
// Add to NotificationManager
let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
print("Pending notifications: \(pending)")
```

### Check Backend Response:
```swift
// Add to APIService.endCurrentPeriod()
print("Period end response: \(response)")
```

---

## Known Limitations

1. **Notifications require permission**: If denied, feature degrades to manual-only
2. **Local attempt tracking**: Resets on app reinstall (acceptable trade-off)
3. **10 AM notification time**: Hardcoded, not user-configurable
4. **2 notification attempts**: Hardcoded limit
5. **Max 2 UI attempts**: Also hardcoded (matches notification attempts)

These are all per the design spec and intentional limitations.
