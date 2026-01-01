# Cycle Tracking Enhancements - Implementation Plan

**Branch**: `feature/cycle-tracking-enhancements`
**Date**: 2026-01-01
**Status**: Planning Complete

## Overview

This plan outlines three interconnected features to enhance cycle tracking in the iOS app:

1. **Onboarding Validation**: Require at least 1 past cycle date to ensure accurate predictions
2. **Intelligent Cycle Prompting**: Smart pattern-based prompting for cycle start (not hardcoded timing)
3. **Calendar View**: Visual calendar with phase shading, historical dates, and add date capability

---

## Feature 1: Onboarding Validation

### Goal
Ensure users provide at least 1 past cycle date during onboarding to enable accurate cycle predictions.

### Current Behavior
- Onboarding allows 0-3 cycle dates
- User can skip by tapping "Skip for Now"
- Backend can work without initial dates but predictions are less accurate

### Desired Behavior
- Require minimum 1 cycle date
- Disable "Continue" button when no dates entered
- Remove "Skip for Now" option
- Update helper text to encourage (not pressure) adding dates

### Implementation

**File**: `StrengthGraceFlow/Features/Onboarding/Views/OnboardingContainerView.swift`

**Changes**:

1. **Update Button Logic** (Lines 539-545):
```swift
// BEFORE:
Button(cycleDates.isEmpty ? "Skip for Now" : "Continue") {
    onComplete()
}
.buttonStyle(SGFPrimaryButtonStyle(isDisabled: isLoading))
.disabled(isLoading)

// AFTER:
Button("Continue") {
    onComplete()
}
.buttonStyle(SGFPrimaryButtonStyle(isDisabled: cycleDates.isEmpty || isLoading))
.disabled(cycleDates.isEmpty || isLoading)
```

2. **Update Helper Text** (Lines 515-526):
```swift
// BEFORE:
if cycleDates.isEmpty {
    VStack(spacing: SGFSpacing.sm) {
        Text("Don't remember exact dates?")
            .font(.sgfCaption)
            .foregroundColor(.sgfTextTertiary)
        Text("You can skip this and begin tracking whenever you're ready")
            .font(.sgfCaption)
            .foregroundColor(.sgfTextTertiary)
            .multilineTextAlignment(.center)
    }
    .padding(.horizontal, SGFSpacing.xl)
}

// AFTER:
if cycleDates.isEmpty {
    VStack(spacing: SGFSpacing.sm) {
        Text("Add your most recent cycle start date")
            .font(.sgfCaption)
            .foregroundColor(.sgfTextSecondary)
            .multilineTextAlignment(.center)
        Text("Even one date helps us understand your rhythm")
            .font(.sgfCaption)
            .foregroundColor(.sgfTextTertiary)
            .multilineTextAlignment(.center)
    }
    .padding(.horizontal, SGFSpacing.xl)
}
```

### Edge Cases
- User tries to continue without date → Button disabled ✓
- User adds then removes date → Button re-disabled ✓
- User adds duplicate date → Already handled (line 549)

### Testing
- [ ] Cannot proceed without at least 1 date
- [ ] Can proceed with 1, 2, or 3 dates
- [ ] Helper text is encouraging
- [ ] Dates save correctly to backend

**Estimated Time**: 30 minutes

---

## Feature 2: Intelligent Cycle Start Prompting

### Goal
Show "Did your cycle start?" banner only when it's likely the user's period is beginning, based on their personal cycle patterns.

### Current Behavior
- Banner shows when `cycleDay > 20` OR no cycle data exists
- Hardcoded logic doesn't account for cycle variability
- Can show too early or too late for many users

### Desired Behavior
- Calculate user's cycle pattern variability from historical data
- Adjust prompt window dynamically based on regularity:
  - Very regular cycles → narrow window (±2 days)
  - Moderately regular → standard window (±3 days)
  - Somewhat irregular → wider window (±4 days)
  - Very irregular → widest window (±5 days)
- Gets smarter as user logs more cycles

### Pattern-Based Algorithm

**Cycle Regularity Classification**:
```
Standard Deviation of Cycle Lengths:
- ≤ 1 day:   Very regular     → ±2 day window
- 1-2 days:  Moderately regular → ±3 day window
- 2-4 days:  Somewhat irregular → ±4 day window
- > 4 days:  Very irregular    → ±5 day window
```

**Examples**:
- Cycles: [28, 28, 29, 28] → Std dev ~0.5 → ±2 day window
- Cycles: [26, 30, 28, 32] → Std dev ~2.4 → ±4 day window
- Only 1 cycle logged → Default ±3 day window

### Implementation

**File**: `StrengthGraceFlow/Features/Today/ViewModels/TodayViewModel.swift`

**Add Helper Function**:
```swift
private func calculateCycleVariability(cycleLengths: [Int]) -> Int {
    guard !cycleLengths.isEmpty else { return 3 }

    // Default window for first cycle
    if cycleLengths.count == 1 {
        return 3
    }

    // Calculate standard deviation
    let mean = Double(cycleLengths.reduce(0, +)) / Double(cycleLengths.count)
    let variance = cycleLengths.reduce(0.0) { sum, length in
        sum + pow(Double(length) - mean, 2)
    } / Double(cycleLengths.count)
    let stdDev = sqrt(variance)

    // Determine window size based on regularity
    switch stdDev {
    case 0...1:
        return 2  // Very regular
    case 1...2:
        return 3  // Moderately regular
    case 2...4:
        return 4  // Somewhat irregular
    default:
        return 5  // Very irregular
    }
}
```

**Update Banner Logic** (Lines 34-42):
```swift
// BEFORE:
if let cycle = currentCycle {
    let isNotMenstruating = cycle.cycle.currentPhase != "menstrual"
    let isLateInCycle = cycle.cycle.cycleDay > 20
    shouldShowLogPeriodBanner = isNotMenstruating && isLateInCycle
}

// AFTER:
if let cycle = currentCycle {
    let isNotMenstruating = cycle.cycle.currentPhase != "menstrual"

    // Get cycle history to calculate variability
    // (This will need to be fetched or passed from cycleHistory)
    let cycleLengths = cycleHistory?.cycles.map { $0.length } ?? []
    let windowSize = calculateCycleVariability(cycleLengths: cycleLengths)

    let avgCycleLength = cycle.averageCycleLength
    let cycleDay = cycle.cycle.cycleDay
    let daysUntilExpected = avgCycleLength - cycleDay

    // Show banner if in prompt window (before or after expected start)
    let isInPromptWindow = (daysUntilExpected >= -windowSize && daysUntilExpected <= windowSize)

    shouldShowLogPeriodBanner = isNotMenstruating && isInPromptWindow
}
```

**Note**: May need to fetch cycle history in `loadCycleInfo()` or add it to the current cycle response.

### Edge Cases
- Only 1 cycle → Use default ±3 day window
- No cycle data → Keep existing fallback behavior
- Very short cycles (< 21 days) → Window might overlap phases (acceptable)
- Very long cycles (> 40 days) → Window appears later (correct)
- Recently logged period → Won't show (in menstrual phase)

### Testing
- [ ] Banner doesn't show early in cycle (day 1-15)
- [ ] Banner shows near expected period for regular cycles
- [ ] Banner window adjusts based on cycle variability
- [ ] Banner doesn't show during menstrual phase
- [ ] Works with 1 cycle (default window)
- [ ] Works with 4+ cycles (calculated window)

**Estimated Time**: 1.5-2 hours

---

## Feature 3: Calendar View with Phase Visualization

### Goal
Replace list-based cycle history with visual calendar showing:
- Full month grid with day cells
- Phase-shaded dates (menstrual, follicular, ovulatory, luteal)
- Past cycle start date markers
- Ability to add cycle dates from calendar
- Month navigation

### Current Behavior
- Cycle tab shows `CycleHistoryView` (scrollable list of past cycles)
- No visual calendar
- Can't see phase predictions on specific dates
- Adding dates only through separate sheet

### Desired Behavior
- Interactive calendar grid as main Cycle tab
- Each date shaded by its predicted phase (subtle opacity)
- Red dot on dates when cycle started
- Today highlighted with border
- Tap any date to add cycle start
- Navigate between months
- Phase legend showing color meanings
- Next period prediction card

### Design System Integration

**Colors** (with 0.3 opacity for background shading):
- Menstrual: `.sgfMenstrual.opacity(0.3)` (terracotta tint)
- Follicular: `.sgfFollicular.opacity(0.3)` (spring/growth colors)
- Ovulatory: `.sgfOvulatory.opacity(0.3)` (peak/bright colors)
- Luteal: `.sgfLuteal.opacity(0.3)` (warm/calm colors)

**Typography**:
- Month/Year header: `.sgfTitle3`
- Day numbers: `.sgfSubheadline`
- Legend labels: `.sgfCaption`
- Section headers: `.sgfHeadline`

**Spacing & Layout**:
- Grid cell spacing: `SGFSpacing.xs`
- Section spacing: `SGFSpacing.lg`
- Card padding: `SGFSpacing.md`
- Corner radius: `SGFCornerRadius.md`

**Colors**:
- Surface backgrounds: `.sgfSurface`
- Screen background: `.sgfBackground`
- Primary accent: `.sgfPrimary` (dusty blue)
- Text hierarchy: `.sgfTextPrimary`, `.sgfTextSecondary`, `.sgfTextTertiary`

### Architecture

**New Files**:

1. **CycleCalendarViewModel.swift**
   - Manages calendar state and data
   - Fetches cycle history (all past dates)
   - Fetches predictions for next 90 days
   - Handles adding new cycle dates
   - Published properties for view binding

2. **CycleCalendarView.swift**
   - Main calendar screen
   - Month navigation controls
   - Calendar grid
   - Phase legend
   - Next period prediction card
   - Add date sheet presentation

3. **CalendarGridView.swift**
   - Month grid layout (7 columns)
   - Day cell creation
   - Phase color mapping
   - Cycle start markers
   - Today highlighting

4. **CalendarDayCell.swift**
   - Individual day cell component
   - Phase background shading
   - Cycle start indicator (red dot)
   - Today border
   - Tap interaction

5. **Supporting Components** (can be inline or separate):
   - `MonthNavigationView` - Previous/Next month buttons
   - `PhaseLegendView` - Color legend for phases
   - `AddCycleDateSheet` - Date picker for adding dates

**Updated Files**:
- `MainTabView.swift` - Replace `CycleHistoryView` with `CycleCalendarView`

### Implementation Details

#### 1. CycleCalendarViewModel.swift

```swift
import Foundation

@MainActor
class CycleCalendarViewModel: ObservableObject {
    @Published var cycleDates: [Date] = []
    @Published var predictions: [CyclePrediction] = []
    @Published var nextPeriodDate: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    func loadCalendarData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load cycle history to get all past start dates
            let historyResponse = try await apiService.getCycleHistory(limit: 50)
            cycleDates = historyResponse.cycles.map { $0.startDate }

            // Load predictions for phase coloring (next 90 days)
            let predictionsResponse = try await apiService.getCyclePredictions(days: 90)
            predictions = predictionsResponse.predictions
            nextPeriodDate = predictionsResponse.nextPeriodStart

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logCycleStart(date: Date) async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await apiService.logPeriod(startDate: date, notes: nil)
            await loadCalendarData() // Reload to update calendar
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
```

#### 2. CycleCalendarView.swift

```swift
import SwiftUI

struct CycleCalendarView: View {
    @StateObject private var viewModel = CycleCalendarViewModel()
    @State private var currentMonth = Date()
    @State private var showingAddDate = false
    @State private var selectedDate = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SGFSpacing.lg) {
                    // Month navigation
                    MonthNavigationView(currentMonth: $currentMonth)

                    // Calendar grid with phase shading
                    CalendarGridView(
                        currentMonth: currentMonth,
                        cycleDates: viewModel.cycleDates,
                        predictions: viewModel.predictions,
                        onDateTap: { date in
                            selectedDate = date
                            showingAddDate = true
                        }
                    )

                    // Phase legend
                    PhaseLegendView()

                    // Upcoming events
                    if let nextPeriod = viewModel.nextPeriodDate {
                        NextPeriodCard(date: nextPeriod)
                    }
                }
                .padding(.horizontal, SGFSpacing.lg)
            }
            .background(Color.sgfBackground)
            .navigationTitle("Cycle Calendar")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        selectedDate = Date()
                        showingAddDate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.sgfPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddDate) {
                AddCycleDateSheet(
                    selectedDate: $selectedDate,
                    onSave: { date in
                        Task {
                            await viewModel.logCycleStart(date: date)
                        }
                    }
                )
            }
            .task {
                await viewModel.loadCalendarData()
            }
        }
    }
}
```

#### 3. CalendarGridView.swift

```swift
import SwiftUI

struct CalendarGridView: View {
    let currentMonth: Date
    let cycleDates: [Date]
    let predictions: [CyclePrediction]
    let onDateTap: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: SGFSpacing.sm) {
            // Weekday headers
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.sgfCaption)
                        .foregroundColor(.sgfTextTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: SGFSpacing.xs) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            isCycleStart: cycleDates.contains {
                                calendar.isDate($0, inSameDayAs: date)
                            },
                            phaseColor: phaseColor(for: date),
                            isToday: calendar.isDateInToday(date),
                            onTap: { onDateTap(date) }
                        )
                    } else {
                        // Empty cell for padding
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding(SGFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                .fill(Color.sgfSurface)
        )
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }

        var dates: [Date?] = []
        var date = monthFirstWeek.start

        while date < monthInterval.end {
            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                dates.append(date)
            } else {
                dates.append(nil)
            }
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }

        return dates
    }

    private func phaseColor(for date: Date) -> Color? {
        guard let prediction = predictions.first(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        }) else {
            return nil
        }

        switch prediction.phase {
        case "menstrual": return .sgfMenstrual.opacity(0.3)
        case "follicular": return .sgfFollicular.opacity(0.3)
        case "ovulatory": return .sgfOvulatory.opacity(0.3)
        case "luteal": return .sgfLuteal.opacity(0.3)
        default: return nil
        }
    }
}
```

#### 4. CalendarDayCell.swift

```swift
import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isCycleStart: Bool
    let phaseColor: Color?
    let isToday: Bool
    let onTap: () -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background phase color
                RoundedRectangle(cornerRadius: 8)
                    .fill(phaseColor ?? Color.clear)

                // Today indicator
                if isToday {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.sgfPrimary, lineWidth: 2)
                }

                VStack(spacing: 2) {
                    Text(dateFormatter.string(from: date))
                        .font(.sgfSubheadline)
                        .foregroundColor(.sgfTextPrimary)

                    // Cycle start indicator
                    if isCycleStart {
                        Circle()
                            .fill(Color.sgfMenstrual)
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
}
```

#### 5. Supporting Components

**MonthNavigationView**:
```swift
struct MonthNavigationView: View {
    @Binding var currentMonth: Date

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    var body: some View {
        HStack {
            Button {
                currentMonth = Calendar.current.date(
                    byAdding: .month,
                    value: -1,
                    to: currentMonth
                ) ?? currentMonth
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.sgfPrimary)
            }

            Spacer()

            Text(monthFormatter.string(from: currentMonth))
                .font(.sgfTitle3)
                .foregroundColor(.sgfTextPrimary)

            Spacer()

            Button {
                currentMonth = Calendar.current.date(
                    byAdding: .month,
                    value: 1,
                    to: currentMonth
                ) ?? currentMonth
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.sgfPrimary)
            }
        }
        .padding(.horizontal, SGFSpacing.md)
    }
}
```

**PhaseLegendView**:
```swift
struct PhaseLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.sm) {
            Text("Phase Guide")
                .font(.sgfHeadline)
                .foregroundColor(.sgfTextPrimary)

            HStack(spacing: SGFSpacing.md) {
                PhaseLegendItem(color: .sgfMenstrual, label: "Menstrual")
                PhaseLegendItem(color: .sgfFollicular, label: "Follicular")
            }

            HStack(spacing: SGFSpacing.md) {
                PhaseLegendItem(color: .sgfOvulatory, label: "Ovulatory")
                PhaseLegendItem(color: .sgfLuteal, label: "Luteal")
            }
        }
        .padding(SGFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                .fill(Color.sgfSurface)
        )
    }
}

struct PhaseLegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: SGFSpacing.xs) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color.opacity(0.3))
                .frame(width: 20, height: 20)

            Text(label)
                .font(.sgfCaption)
                .foregroundColor(.sgfTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```

**AddCycleDateSheet**:
```swift
struct AddCycleDateSheet: View {
    @Binding var selectedDate: Date
    let onSave: (Date) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Cycle Start Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()
            }
            .background(Color.sgfBackground)
            .navigationTitle("Add Cycle Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.sgfTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(selectedDate)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.sgfPrimary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
```

#### 6. Update MainTabView.swift

```swift
// Replace CycleHistoryView with CycleCalendarView
// Around line 27-30

// BEFORE:
CycleHistoryView()
    .tabItem {
        Label("Cycle", systemImage: "calendar")
    }
    .tag(2)

// AFTER:
CycleCalendarView()
    .tabItem {
        Label("Calendar", systemImage: "calendar")
    }
    .tag(2)
```

### Edge Cases
- **Past months**: Show historical cycle starts, no predictions
- **Future months**: Show predicted phases, no cycle starts (until logged)
- **Tapping past date**: Allow adding historical data
- **Tapping future date**: Could show info message or allow pre-logging
- **Duplicate dates**: Backend should handle gracefully
- **Long history (50+ cycles)**: May need pagination later
- **Month navigation speed**: Predictions already cover 90 days
- **Phase accuracy**: Trust backend predictions
- **Calendar grid**: Handle varying month lengths properly

### Testing
- [ ] Current month displays correctly with proper layout
- [ ] Can navigate to past/future months
- [ ] Past cycle dates show red dot indicator
- [ ] Phase colors display correctly and match legend
- [ ] Today is highlighted with border
- [ ] Can tap any past date to add cycle start
- [ ] Adding date updates calendar immediately
- [ ] Design system colors/typography/spacing used throughout
- [ ] Phase boundaries align with backend predictions
- [ ] Next period prediction card shows correct date

**Estimated Time**: 4-6 hours

---

## Implementation Sequence

### Phase 1: Onboarding (30 min)
1. Update `OnboardingContainerView.swift` button and text
2. Test onboarding flow
3. Commit: "feat: require at least 1 cycle date in onboarding"

### Phase 2: Smart Prompting (1.5-2 hours)
1. Add cycle variability calculation function
2. Update banner logic in `TodayViewModel.swift`
3. Test with various cycle patterns
4. Commit: "feat: implement intelligent cycle start prompting based on patterns"

### Phase 3: Calendar View (4-6 hours)
1. Create `CycleCalendarViewModel.swift`
2. Create `CycleCalendarView.swift` with basic layout
3. Create `CalendarGridView.swift` with month calculation
4. Create `CalendarDayCell.swift` with phase coloring
5. Add supporting components (legend, navigation, sheet)
6. Update `MainTabView.swift`
7. Test calendar interactions and visual design
8. Commit: "feat: add visual calendar with phase shading and date management"

**Total Estimated Time**: 6-8.5 hours

---

## Testing Checklist

### Onboarding
- [ ] Cannot proceed without at least 1 date
- [ ] Can proceed with 1, 2, or 3 dates
- [ ] Helper text is encouraging, not pushy
- [ ] Dates save correctly to backend
- [ ] No regression in flow

### Smart Prompting
- [ ] Banner doesn't show early in cycle
- [ ] Banner shows near expected period
- [ ] Window size adjusts based on regularity:
  - [ ] Regular cycles use ±2 day window
  - [ ] Irregular cycles use ±4-5 day window
- [ ] Default ±3 day window with 1 cycle
- [ ] Banner doesn't show during menstrual phase
- [ ] No crashes with edge case data

### Calendar View
- [ ] Month displays correctly with proper grid
- [ ] Week headers show correctly (S M T W T F S)
- [ ] Day numbers are readable
- [ ] Navigation arrows work (previous/next month)
- [ ] Past cycle dates show red dot
- [ ] Phase colors match design system
- [ ] Phase colors have proper opacity (0.3)
- [ ] Today is highlighted with border
- [ ] Can tap any date to open add sheet
- [ ] Add sheet saves date correctly
- [ ] Calendar updates after adding date
- [ ] Legend shows all 4 phases
- [ ] Legend colors match calendar
- [ ] Next period card shows if prediction exists
- [ ] Spacing/typography uses design system
- [ ] Works on different screen sizes
- [ ] Smooth scrolling and navigation

---

## Success Criteria

### Feature 1: Onboarding
✅ All new users must provide at least 1 cycle date
✅ Flow feels natural and encouraging, not blocking
✅ Backend receives initial data for accurate predictions

### Feature 2: Smart Prompting
✅ Prompt timing adapts to user's cycle patterns
✅ Regular cycles get narrow window (less prompts)
✅ Irregular cycles get wider window (more coverage)
✅ System improves accuracy as more data is logged
✅ Fewer false prompts/annoyances for users

### Feature 3: Calendar View
✅ Users can visually see their cycle phases on calendar
✅ Easy to understand which dates are which phase
✅ Past cycle dates are clearly marked
✅ Can add cycle dates directly from calendar
✅ Design matches brand identity (terracotta/dusty blue)
✅ Smooth, intuitive user experience

---

## Future Enhancements

- **Calendar View**:
  - Add notes to specific dates
  - Show symptoms on calendar
  - Export calendar to device calendar
  - Week view option

- **Smart Prompting**:
  - ML model for better irregularity prediction
  - Consider other factors (stress, travel, etc.)
  - Adaptive learning from user's logging behavior

- **Data Management**:
  - Bulk import of historical data
  - Edit/delete cycle dates from calendar
  - Cycle length trends over time

---

## Related Files

### Files to Modify
- `StrengthGraceFlow/Features/Onboarding/Views/OnboardingContainerView.swift`
- `StrengthGraceFlow/Features/Today/ViewModels/TodayViewModel.swift`
- `StrengthGraceFlow/Features/Today/Views/MainTabView.swift`

### Files to Create
- `StrengthGraceFlow/Features/Cycle/ViewModels/CycleCalendarViewModel.swift`
- `StrengthGraceFlow/Features/Cycle/Views/CycleCalendarView.swift`
- `StrengthGraceFlow/Features/Cycle/Views/Components/CalendarGridView.swift`
- `StrengthGraceFlow/Features/Cycle/Views/Components/CalendarDayCell.swift`

### Supporting Files (inline or separate)
- Month navigation component
- Phase legend component
- Add date sheet component
- Next period card component

---

## Notes

- All changes use existing design system (SGF prefixed constants)
- API endpoints already exist for all required data
- Backend predictions drive phase coloring
- Calendar view replaces list view but CycleHistoryView still exists in codebase
- Smart prompting gets more accurate over time automatically
- Implementation can be done in parallel by 3 developers (1 per feature)
