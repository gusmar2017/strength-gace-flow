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

                // Cycle start indicator - ring around the cell
                if isCycleStart {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.sgfMenstrual, lineWidth: 2.5)
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
                        .fontWeight(isCycleStart ? .semibold : .regular)

                    // Small dot indicator for cycle start
                    if isCycleStart {
                        Circle()
                            .fill(Color.sgfMenstrual)
                            .frame(width: 5, height: 5)
                    }
                }
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
}
