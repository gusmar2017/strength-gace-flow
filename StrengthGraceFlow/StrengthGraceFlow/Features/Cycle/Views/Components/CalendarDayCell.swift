//
//  CalendarDayCell.swift
//  StrengthGraceFlow
//
//  Individual day cell for calendar grid
//

import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isCycleStart: Bool
    let isPredictedStart: Bool
    let phaseColor: Color?
    let isToday: Bool
    let onTap: () -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        ZStack {
            // Background phase color
            RoundedRectangle(cornerRadius: 8)
                .fill(phaseColor ?? Color.clear)

            // Actual cycle start indicator - solid ring
            if isCycleStart {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.sgfMenstrual, lineWidth: 2.5)
            }

            // Predicted cycle start indicator - dashed ring
            if isPredictedStart {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.sgfMenstrual, style: StrokeStyle(lineWidth: 2.5, dash: [4, 4]))
            }

            // Today indicator (overlays on top of cycle start if both apply)
            if isToday {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.sgfPrimary, lineWidth: 2)
            }

            VStack(spacing: 2) {
                Text(dateFormatter.string(from: date))
                    .font(.sgfSubheadline)
                    .foregroundColor(.sgfTextPrimary)
                    .fontWeight((isCycleStart || isPredictedStart) ? .semibold : .regular)

                // Small dot indicator for cycle start (solid for actual, hollow for predicted)
                if isCycleStart {
                    Circle()
                        .fill(Color.sgfMenstrual)
                        .frame(width: 5, height: 5)
                } else if isPredictedStart {
                    Circle()
                        .stroke(Color.sgfMenstrual, lineWidth: 1.5)
                        .frame(width: 5, height: 5)
                }
            }
        }
        .frame(height: 44)
        .contentShape(Rectangle())
        .onTapGesture {
            print("🟢 CalendarDayCell tapped: \(date)")
            onTap()
        }
    }
}
