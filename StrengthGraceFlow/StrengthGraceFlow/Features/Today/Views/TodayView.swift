//
//  TodayView.swift
//  StrengthGraceFlow
//
//  Today screen showing current cycle phase and recommendations
//

import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var showingLogPeriod = false
    @State private var currentPhase: CyclePhase = .follicular
    @State private var cycleDay = 8

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SGFSpacing.lg) {
                    // Log period banner (show if needed)
                    if viewModel.shouldShowLogPeriodBanner {
                        LogPeriodBanner {
                            showingLogPeriod = true
                        }
                        .padding(.horizontal, SGFSpacing.lg)
                    }

                    // Phase card
                    PhaseCard(phase: currentPhase, cycleDay: cycleDay)
                        .padding(.horizontal, SGFSpacing.lg)

                    // Quick stats
                    QuickStatsView(phase: currentPhase)
                        .padding(.horizontal, SGFSpacing.lg)

                    // Today's recommendation
                    TodayRecommendationCard(phase: currentPhase)
                        .padding(.horizontal, SGFSpacing.lg)

                    // Phase tips
                    PhaseTipsCard(phase: currentPhase)
                        .padding(.horizontal, SGFSpacing.lg)
                }
                .padding(.vertical, SGFSpacing.md)
            }
            .background(Color.sgfBackground)
            .navigationTitle("Today")
            .sheet(isPresented: $showingLogPeriod) {
                LogPeriodSheet(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Log Period Banner

struct LogPeriodBanner: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SGFSpacing.md) {
                Image(systemName: "drop.circle.fill")
                    .font(.title2)
                    .foregroundColor(.sgfMenstrual)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Did your period start?")
                        .font(.sgfSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.sgfTextPrimary)

                    Text("Tap to log for better predictions")
                        .font(.sgfCaption)
                        .foregroundColor(.sgfTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.sgfTextTertiary)
            }
            .padding(SGFSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .fill(Color.sgfMenstrual.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .stroke(Color.sgfMenstrual.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Log Period Sheet

struct LogPeriodSheet: View {
    @ObservedObject var viewModel: TodayViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Start Date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log Period Start")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.logPeriod(date: selectedDate, notes: notes)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Cycle Phase

enum CyclePhase: String, CaseIterable {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case ovulatory = "Ovulatory"
    case luteal = "Luteal"

    var color: Color {
        switch self {
        case .menstrual: return .sgfMenstrual
        case .follicular: return .sgfFollicular
        case .ovulatory: return .sgfOvulatory
        case .luteal: return .sgfLuteal
        }
    }

    var icon: String {
        switch self {
        case .menstrual: return "drop.fill"
        case .follicular: return "leaf.fill"
        case .ovulatory: return "sun.max.fill"
        case .luteal: return "moon.fill"
        }
    }

    var description: String {
        switch self {
        case .menstrual:
            return "Rest and recover. Focus on gentle movement."
        case .follicular:
            return "Energy rising! Great time to try new things."
        case .ovulatory:
            return "Peak energy! Push yourself with high intensity."
        case .luteal:
            return "Wind down. Focus on strength and stability."
        }
    }

    var recommendedIntensity: String {
        switch self {
        case .menstrual: return "Low"
        case .follicular: return "Medium"
        case .ovulatory: return "High"
        case .luteal: return "Medium-Low"
        }
    }

    var workoutTypes: [String] {
        switch self {
        case .menstrual:
            return ["Yoga", "Walking", "Stretching", "Light Pilates"]
        case .follicular:
            return ["HIIT", "Running", "Dance", "Strength Training"]
        case .ovulatory:
            return ["High Intensity", "Heavy Lifting", "Spin", "CrossFit"]
        case .luteal:
            return ["Pilates", "Swimming", "Moderate Weights", "Barre"]
        }
    }
}

// MARK: - Phase Card

struct PhaseCard: View {
    let phase: CyclePhase
    let cycleDay: Int

    var body: some View {
        VStack(spacing: SGFSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: SGFSpacing.xs) {
                    Text("Day \(cycleDay)")
                        .font(.sgfCaption)
                        .foregroundColor(.white.opacity(0.8))

                    Text(phase.rawValue)
                        .font(.sgfLargeTitle)
                        .foregroundColor(.white)

                    Text("Phase")
                        .font(.sgfSubheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: phase.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.9))
            }

            Text(phase.description)
                .font(.sgfBody)
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(SGFSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.lg)
                .fill(
                    LinearGradient(
                        colors: [phase.color, phase.color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Quick Stats

struct QuickStatsView: View {
    let phase: CyclePhase

    var body: some View {
        HStack(spacing: SGFSpacing.md) {
            StatCard(
                title: "Intensity",
                value: phase.recommendedIntensity,
                icon: "flame.fill",
                color: .sgfAccent
            )

            StatCard(
                title: "Energy",
                value: energyLevel,
                icon: "bolt.fill",
                color: .sgfPrimary
            )
        }
    }

    var energyLevel: String {
        switch phase {
        case .menstrual: return "Rest"
        case .follicular: return "Rising"
        case .ovulatory: return "Peak"
        case .luteal: return "Steady"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: SGFSpacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.sgfHeadline)
                .foregroundColor(.sgfTextPrimary)

            Text(title)
                .font(.sgfCaption)
                .foregroundColor(.sgfTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(SGFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                .fill(Color.sgfSurface)
        )
    }
}

// MARK: - Today's Recommendation

struct TodayRecommendationCard: View {
    let phase: CyclePhase

    var body: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.md) {
            Text("Recommended for Today")
                .font(.sgfHeadline)
                .foregroundColor(.sgfTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SGFSpacing.sm) {
                    ForEach(phase.workoutTypes, id: \.self) { workout in
                        WorkoutChip(title: workout, color: phase.color)
                    }
                }
            }

            Button {
                // TODO: Navigate to workouts
            } label: {
                HStack {
                    Text("View Workouts")
                        .font(.sgfSubheadline)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.sgfPrimary)
            }
        }
        .padding(SGFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                .fill(Color.sgfSurface)
        )
    }
}

struct WorkoutChip: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.sgfSubheadline)
            .foregroundColor(color)
            .padding(.horizontal, SGFSpacing.md)
            .padding(.vertical, SGFSpacing.sm)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }
}

// MARK: - Phase Tips

struct PhaseTipsCard: View {
    let phase: CyclePhase

    var tips: [String] {
        switch phase {
        case .menstrual:
            return [
                "Honor your body's need for rest",
                "Stay hydrated and nourished",
                "Gentle stretching can ease cramps"
            ]
        case .follicular:
            return [
                "Try something new - your brain is primed for learning",
                "Gradually increase workout intensity",
                "Great time for cardio and challenging workouts"
            ]
        case .ovulatory:
            return [
                "Take advantage of peak energy levels",
                "Push yourself with high-intensity workouts",
                "Perfect time for group fitness classes"
            ]
        case .luteal:
            return [
                "Focus on strength over cardio",
                "Include more protein in your diet",
                "Prioritize sleep and recovery"
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.md) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.sgfAccent)
                Text("Phase Tips")
                    .font(.sgfHeadline)
                    .foregroundColor(.sgfTextPrimary)
            }

            VStack(alignment: .leading, spacing: SGFSpacing.sm) {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: SGFSpacing.sm) {
                        Circle()
                            .fill(phase.color)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        Text(tip)
                            .font(.sgfSubheadline)
                            .foregroundColor(.sgfTextSecondary)
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
}

#Preview {
    TodayView()
}
