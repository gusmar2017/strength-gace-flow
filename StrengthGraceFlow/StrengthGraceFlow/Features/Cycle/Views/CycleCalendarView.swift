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
    @State private var selectedDate = Date()

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
            .task {
                await viewModel.loadCalendarData()
            }
        }
    }
}

// MARK: - Month Navigation View

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

#Preview {
    CycleCalendarView()
}
