//
//  CalendarGridView.swift
//  StrengthGraceFlow
//
//  Calendar month grid with phase shading
//

import SwiftUI

struct CalendarGridView: View {
    let currentMonth: Date
    let cycleDates: [Date]
    let predictions: [PhasePrediction]
    let onDateTap: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: SGFSpacing.sm) {
            // Weekday headers
            HStack {
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { _, day in
                    Text(day)
                        .font(.sgfCaption)
                        .foregroundColor(.sgfTextTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: SGFSpacing.xs) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
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
