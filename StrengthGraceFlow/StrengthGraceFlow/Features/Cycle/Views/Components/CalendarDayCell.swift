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
