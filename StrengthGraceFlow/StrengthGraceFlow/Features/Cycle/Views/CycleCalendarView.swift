//
//  CycleCalendarView.swift
//  StrengthGraceFlow
//
//  Visual calendar view with phase shading and cycle management
//

import SwiftUI

struct CycleCalendarView: View {
    @StateObject private var viewModel = CycleCalendarViewModel()
    @State private var currentMonth = Date()
    @State private var showingAddDate = false
    @State private var showingDaySummary = false
    @State private var selectedDate = Date()
    @State private var dragOffset: CGFloat = 0

    private let calendar = Calendar.current

    private var canNavigateForward: Bool {
        guard let currentMonthStart = calendar.dateInterval(of: .month, for: currentMonth)?.start,
              let todayMonthStart = calendar.dateInterval(of: .month, for: Date())?.start else {
            return false
        }
        return currentMonthStart < todayMonthStart
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

                            // Calendar grid with phase shading and swipe support
                            CalendarGridView(
                                currentMonth: currentMonth,
                                cycleDates: viewModel.cycleDates,
                                predictions: viewModel.predictions,
                                onDateTap: { date in
                                    selectedDate = date
                                    showingDaySummary = true
                                }
                            )
                            .offset(x: dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        dragOffset = value.translation.width
                                    }
                                    .onEnded { value in
                                        let threshold: CGFloat = 50

                                        if value.translation.width > threshold {
                                            // Swipe right - previous month
                                            withAnimation(.spring(response: 0.3)) {
                                                currentMonth = calendar.date(
                                                    byAdding: .month,
                                                    value: -1,
                                                    to: currentMonth
                                                ) ?? currentMonth
                                                dragOffset = 0
                                            }
                                        } else if value.translation.width < -threshold && canNavigateForward {
                                            // Swipe left - next month (only if allowed)
                                            withAnimation(.spring(response: 0.3)) {
                                                currentMonth = calendar.date(
                                                    byAdding: .month,
                                                    value: 1,
                                                    to: currentMonth
                                                ) ?? currentMonth
                                                dragOffset = 0
                                            }
                                        } else {
                                            // Reset if threshold not met
                                            withAnimation(.spring(response: 0.3)) {
                                                dragOffset = 0
                                            }
                                        }
                                    }
                            )

                            // Phase legend
                            PhaseLegendView()

                            // Next period prediction
                            if let nextPeriod = viewModel.nextPeriodDate {
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
                        selectedDate = Date()
                        showingAddDate = true
                    } label: {
                        Image(systemName: "plus")
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
            .sheet(isPresented: $showingDaySummary) {
                CycleDaySummarySheet(
                    date: selectedDate,
                    cycleDates: viewModel.cycleDates,
                    predictions: viewModel.predictions
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

// MARK: - Phase Legend View

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
    let predictions: [PhasePrediction]
    @Environment(\.dismiss) var dismiss

    private let calendar = Calendar.current

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    private var cycleDay: Int? {
        // Find the most recent cycle start before or on this date
        let sortedDates = cycleDates.sorted()
        guard let mostRecentStart = sortedDates.last(where: { $0 <= date }) else {
            return nil
        }

        let days = calendar.dateComponents([.day], from: mostRecentStart, to: date).day ?? 0
        return days + 1
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

    var body: some View {
        NavigationStack {
            VStack(spacing: SGFSpacing.lg) {
                // Date Header
                VStack(spacing: SGFSpacing.xs) {
                    Text(dateFormatter.string(from: date))
                        .font(.sgfTitle2)
                        .foregroundColor(.sgfTextPrimary)

                    if isFutureDate {
                        Text("Future Date")
                            .font(.sgfCaption)
                            .foregroundColor(.sgfTextTertiary)
                    }
                }
                .padding(.top, SGFSpacing.lg)

                Divider()

                // Cycle Day Info
                if let day = cycleDay {
                    VStack(spacing: SGFSpacing.sm) {
                        Text("Day \(day)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.sgfPrimary)

                        Text("of your cycle")
                            .font(.sgfSubheadline)
                            .foregroundColor(.sgfTextSecondary)
                    }
                    .padding(.vertical, SGFSpacing.md)
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
            .background(Color.sgfBackground)
            .navigationTitle("Cycle Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.sgfPrimary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    CycleCalendarView()
}
