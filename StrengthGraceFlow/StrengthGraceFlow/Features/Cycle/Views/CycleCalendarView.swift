//
//  CycleCalendarView.swift
//  StrengthGraceFlow
//
//  Visual calendar view with phase shading and cycle management
//

import SwiftUI

// Wrapper to make Date identifiable for .sheet(item:) pattern
struct IdentifiableDate: Identifiable {
    let id: TimeInterval
    let date: Date

    init(_ date: Date) {
        self.date = date
        self.id = date.timeIntervalSince1970
    }
}

struct CycleCalendarView: View {
    @StateObject private var viewModel = CycleCalendarViewModel()
    @State private var currentMonth = Date()
    @State private var showingAddDate = false
    @State private var selectedDateForSheet: IdentifiableDate?
    @State private var addCycleDate = Date()

    private let calendar = Calendar.current

    private var canNavigateForward: Bool {
        guard let currentMonthStart = calendar.dateInterval(of: .month, for: currentMonth)?.start,
              let todayMonthStart = calendar.dateInterval(of: .month, for: Date())?.start else {
            return false
        }
        return currentMonthStart < todayMonthStart
    }

    // Show prompt if predicted period date has passed and user hasn't logged it
    private var shouldShowLogPeriodPrompt: Bool {
        guard let predictedDate = viewModel.nextPeriodDate else { return false }

        let today = Date()
        let daysSincePrediction = calendar.dateComponents([.day], from: predictedDate, to: today).day ?? 0

        // Show prompt if we're within 3 days before or 7 days after predicted date
        // and the last logged cycle is more than 21 days ago
        if let lastCycleDate = viewModel.cycleDates.sorted().last {
            let daysSinceLastLog = calendar.dateComponents([.day], from: lastCycleDate, to: today).day ?? 0
            return daysSinceLastLog >= 21 && daysSincePrediction >= -3
        }

        return false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgfBackground.ignoresSafeArea()

                if viewModel.isLoading && viewModel.cycleDates.isEmpty {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: SGFSpacing.lg) {
                            // Month navigation
                            MonthNavigationView(
                                currentMonth: $currentMonth,
                                canNavigateForward: canNavigateForward
                            )

                            // Calendar grid with phase shading
                            CalendarGridView(
                                currentMonth: currentMonth,
                                cycleDates: viewModel.cycleDates,
                                nextPeriodDate: viewModel.nextPeriodDate,
                                predictions: viewModel.predictions,
                                onDateTap: { date in
                                    selectedDateForSheet = IdentifiableDate(date)
                                }
                            )

                            // Prompt to log period if predicted date has passed
                            if shouldShowLogPeriodPrompt {
                                LogPeriodPromptCard(
                                    predictedDate: viewModel.nextPeriodDate ?? Date(),
                                    onLogPeriod: {
                                        showingAddDate = true
                                    }
                                )
                            }

                            // Next period prediction (only show if not prompting to log)
                            if !shouldShowLogPeriodPrompt, let nextPeriod = viewModel.nextPeriodDate {
                                NextPeriodCard(date: nextPeriod)
                            }
                        }
                        .padding(.horizontal, SGFSpacing.lg)
                        .padding(.vertical, SGFSpacing.md)
                    }
                }
            }
            .navigationTitle("Cycle Calendar")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddDate = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDate) {
                AddCycleDateSheet(
                    selectedDate: $addCycleDate,
                    onSave: { date in
                        Task {
                            await viewModel.logCycleStart(date: date)
                        }
                    }
                )
            }
            .sheet(item: $selectedDateForSheet) { identifiableDate in
                CycleDaySummarySheet(
                    date: identifiableDate.date,
                    cycleDates: viewModel.cycleDates,
                    cycleHistory: viewModel.cycleHistory,
                    predictions: viewModel.predictions,
                    viewModel: viewModel
                )
            }
            .task {
                await viewModel.loadCalendarData()
            }
        }
    }
}

// MARK: - Month Navigation View

struct MonthNavigationView: View {
    @Binding var currentMonth: Date
    let canNavigateForward: Bool

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
                if canNavigateForward {
                    currentMonth = Calendar.current.date(
                        byAdding: .month,
                        value: 1,
                        to: currentMonth
                    ) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(canNavigateForward ? .sgfPrimary : .sgfTextTertiary)
            }
            .disabled(!canNavigateForward)
        }
        .padding(.horizontal, SGFSpacing.md)
    }
}

// MARK: - Log Period Prompt Card

struct LogPeriodPromptCard: View {
    let predictedDate: Date
    let onLogPeriod: () -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private var daysLate: Int {
        let days = Calendar.current.dateComponents([.day], from: predictedDate, to: Date()).day ?? 0
        return max(0, days)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.md) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.sgfPrimary)

                VStack(alignment: .leading, spacing: SGFSpacing.xs) {
                    Text("Did your period start?")
                        .font(.sgfHeadline)
                        .foregroundColor(.sgfTextPrimary)

                    if daysLate > 0 {
                        Text("\(daysLate) days since predicted start")
                            .font(.sgfCaption)
                            .foregroundColor(.sgfTextSecondary)
                    } else {
                        Text("Expected around \(dateFormatter.string(from: predictedDate))")
                            .font(.sgfCaption)
                            .foregroundColor(.sgfTextSecondary)
                    }
                }

                Spacer()
            }

            Button(action: onLogPeriod) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Log Period Start")
                }
                .font(.sgfSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, SGFSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: SGFCornerRadius.sm)
                        .fill(Color.sgfPrimary)
                )
            }
        }
        .padding(SGFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                .fill(Color.sgfMenstrual.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                        .stroke(Color.sgfMenstrual.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Next Period Card

struct NextPeriodCard: View {
    let date: Date

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.sm) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.sgfPrimary)
                Text("Next Period Prediction")
                    .font(.sgfHeadline)
                    .foregroundColor(.sgfTextPrimary)
            }

            HStack(alignment: .firstTextBaseline) {
                Text(dateFormatter.string(from: date))
                    .font(.sgfTitle3)
                    .foregroundColor(.sgfPrimary)

                Spacer()

                if daysUntil > 0 {
                    Text("\(daysUntil) days")
                        .font(.sgfSubheadline)
                        .foregroundColor(.sgfTextSecondary)
                } else if daysUntil == 0 {
                    Text("Today")
                        .font(.sgfSubheadline)
                        .foregroundColor(.sgfPrimary)
                }
            }

            Text("Based on your cycle patterns")
                .font(.sgfCaption)
                .foregroundColor(.sgfTextTertiary)
        }
        .padding(SGFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                .fill(Color.sgfSurface)
        )
    }
}

// MARK: - Add Cycle Date Sheet

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

// MARK: - Cycle Day Summary Sheet

struct CycleDaySummarySheet: View {
    let date: Date
    let cycleDates: [Date]
    let cycleHistory: [CycleData]
    let predictions: [PhasePrediction]
    @ObservedObject var viewModel: CycleCalendarViewModel
    @Environment(\.dismiss) var dismiss

    private let calendar = Calendar.current

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    private var cycleDay: Int? {
        // Find the most recent cycle start before or on this date (calendar-day aware)
        let sortedDates = cycleDates.sorted()

        // Normalize to start of day for consistent comparison across timezones
        let targetDayStart = calendar.startOfDay(for: date)

        guard let mostRecentStart = sortedDates.last(where: { cycleDate in
            let cycleDayStart = calendar.startOfDay(for: cycleDate)
            return cycleDayStart <= targetDayStart
        }) else {
            return nil
        }

        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: mostRecentStart), to: targetDayStart).day ?? 0
        return days + 1
    }

    private var currentCycleForDate: CycleData? {
        // Find the cycle that this date belongs to
        let sortedCycles = cycleHistory.sorted { $0.startDate > $1.startDate }
        return sortedCycles.first { cycle in
            cycle.startDate <= date
        }
    }

    private var phaseInfo: (phase: String, color: Color, description: String)? {
        guard let prediction = predictions.first(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        }) else {
            return nil
        }

        switch prediction.phase {
        case "menstrual":
            return ("Menstrual Phase", .sgfMenstrual, "Your period. Estrogen and progesterone are at their lowest, which may lower energy and increase inflammation. Your body is shedding the uterine lining, so prioritize rest, gentle movement, and anti-inflammatory foods.")
        case "follicular":
            return ("Follicular Phase", .sgfFollicular, "Energy is rising as estrogen increases, boosting mood, focus, and strength. This is an ideal time to start new projects, try challenging workouts, and build muscle as your body is primed for growth and recovery.")
        case "ovulatory":
            return ("Ovulatory Phase", .sgfOvulatory, "Peak energy and strength! Estrogen peaks and testosterone rises, maximizing physical performance, confidence, and social energy. This is your power phase—perfect for PRs, intense workouts, and important conversations.")
        case "luteal":
            return ("Luteal Phase", .sgfLuteal, "Progesterone rises while estrogen declines, which can increase fatigue, cravings, and emotional sensitivity. Your metabolism is higher, so fuel adequately and shift to moderate exercise, yoga, and self-care practices.")
        default:
            return nil
        }
    }

    private var isFutureDate: Bool {
        date > Date()
    }

    private var isCycleStart: Bool {
        cycleDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }

    private var isPredictedStart: Bool {
        guard let nextPeriod = viewModel.nextPeriodDate else { return false }
        return calendar.isDate(nextPeriod, inSameDayAs: date) && isFutureDate
    }

    var body: some View {
        VStack(spacing: SGFSpacing.lg) {
            // Drag indicator spacer
            Color.clear.frame(height: SGFSpacing.md)

            // Cycle Day Info
            if let day = cycleDay {
                VStack(spacing: SGFSpacing.sm) {
                    // Show special indicator for cycle start dates
                    if isCycleStart {
                        HStack(spacing: SGFSpacing.xs) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 20))
                                .foregroundColor(.sgfMenstrual)
                            Text("Period Start")
                                .font(.sgfSubheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.sgfMenstrual)
                        }
                        .padding(.bottom, SGFSpacing.xs)
                    } else if isPredictedStart {
                        HStack(spacing: SGFSpacing.xs) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 20))
                                .foregroundColor(.sgfPrimary)
                            Text("Predicted Period Start")
                                .font(.sgfSubheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.sgfPrimary)
                        }
                        .padding(.bottom, SGFSpacing.xs)
                    }

                    Text("Day \(day)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.sgfPrimary)

                    Text(dateFormatter.string(from: date))
                        .font(.sgfSubheadline)
                        .foregroundColor(.sgfTextSecondary)

                    if isFutureDate {
                        Text("Predicted")
                            .font(.sgfCaption)
                            .foregroundColor(.sgfTextTertiary)
                    }
                }
                .padding(.vertical, SGFSpacing.xs)
            } else {
                VStack(spacing: SGFSpacing.sm) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 36))
                        .foregroundColor(.sgfTextTertiary)

                    Text("No cycle data for this date")
                        .font(.sgfSubheadline)
                        .foregroundColor(.sgfTextSecondary)

                    Text("Log more cycle starts to see predictions")
                        .font(.sgfCaption)
                        .foregroundColor(.sgfTextTertiary)
                }
                .padding(.vertical, SGFSpacing.md)
            }

            // Phase Info
            if let info = phaseInfo {
                VStack(alignment: .leading, spacing: SGFSpacing.md) {
                    HStack {
                        Circle()
                            .fill(info.color)
                            .frame(width: 12, height: 12)

                        Text(info.phase)
                            .font(.sgfHeadline)
                            .foregroundColor(.sgfTextPrimary)
                    }

                    Text(info.description)
                        .font(.sgfBody)
                        .foregroundColor(.sgfTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(SGFSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                        .fill(info.color.opacity(0.1))
                )
            }

            Spacer()
        }
        .padding(.horizontal, SGFSpacing.lg)
        .padding(.top, SGFSpacing.md)
        .background(Color.sgfBackground)
        .presentationDetents([.fraction(0.5), .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    CycleCalendarView()
}
