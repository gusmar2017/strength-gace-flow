//
//  WorkoutListView.swift
//  StrengthGraceFlow
//
//  Workout library with filtering by phase and category
//

import SwiftUI

struct WorkoutListView: View {
    @State private var selectedCategory: WorkoutCategory?
    @State private var selectedPhase: WorkoutCyclePhase?
    @State private var workouts: [WorkoutSummary] = WorkoutSummary.placeholders
    @State private var selectedWorkout: WorkoutSummary?

    var filteredWorkouts: [WorkoutSummary] {
        var result = workouts

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if let phase = selectedPhase {
            result = result.filter { $0.recommendedPhases.contains(phase) }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SGFSpacing.lg) {
                    // Filter chips
                    filterSection

                    // Workouts grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: SGFSpacing.md
                    ) {
                        ForEach(filteredWorkouts) { workout in
                            WorkoutCard(workout: workout)
                                .onTapGesture {
                                    selectedWorkout = workout
                                }
                        }
                    }
                    .padding(.horizontal, SGFSpacing.lg)
                }
                .padding(.vertical, SGFSpacing.md)
            }
            .background(Color.sgfBackground)
            .navigationTitle("Workouts")
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
    }

    var filterSection: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.md) {
            // Phase filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SGFSpacing.sm) {
                    FilterChip(
                        title: "All Phases",
                        isSelected: selectedPhase == nil,
                        color: .sgfPrimary
                    ) {
                        selectedPhase = nil
                    }

                    ForEach(WorkoutCyclePhase.allCases, id: \.self) { phase in
                        FilterChip(
                            title: phase.displayName,
                            isSelected: selectedPhase == phase,
                            color: phase.color
                        ) {
                            selectedPhase = phase
                        }
                    }
                }
                .padding(.horizontal, SGFSpacing.lg)
            }

            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SGFSpacing.sm) {
                    FilterChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        color: .sgfTextSecondary
                    ) {
                        selectedCategory = nil
                    }

                    ForEach(WorkoutCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.displayName,
                            isSelected: selectedCategory == category,
                            color: .sgfTextSecondary
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, SGFSpacing.lg)
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.sgfSubheadline)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, SGFSpacing.md)
                .padding(.vertical, SGFSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.15))
                )
        }
    }
}

// MARK: - Workout Card

struct WorkoutCard: View {
    let workout: WorkoutSummary

    var body: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.sm) {
            // Thumbnail placeholder
            ZStack {
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .fill(workout.category.color.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fit)

                Image(systemName: workout.category.icon)
                    .font(.system(size: 30))
                    .foregroundColor(workout.category.color)
            }

            VStack(alignment: .leading, spacing: SGFSpacing.xs) {
                Text(workout.title)
                    .font(.sgfSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.sgfTextPrimary)
                    .lineLimit(2)

                HStack(spacing: SGFSpacing.xs) {
                    Label("\(workout.durationMinutes) min", systemImage: "clock")
                    Spacer()
                    Text(workout.intensity.displayName)
                        .foregroundColor(workout.intensity.color)
                }
                .font(.sgfCaption)
                .foregroundColor(.sgfTextSecondary)
            }
        }
        .padding(SGFSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                .fill(Color.sgfSurface)
        )
    }
}

// MARK: - Models

enum WorkoutCategory: String, CaseIterable {
    case strength, cardio, yoga, pilates, hiit, stretching, barre, dance

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .strength: return "figure.strengthtraining.traditional"
        case .cardio: return "figure.run"
        case .yoga: return "figure.yoga"
        case .pilates: return "figure.pilates"
        case .hiit: return "flame.fill"
        case .stretching: return "figure.flexibility"
        case .barre: return "figure.barre"
        case .dance: return "figure.dance"
        }
    }

    var color: Color {
        switch self {
        case .strength: return .sgfPrimary
        case .cardio: return .sgfSecondary
        case .yoga: return .sgfFollicular
        case .pilates: return .sgfLuteal
        case .hiit: return .sgfOvulatory
        case .stretching: return .sgfFollicular
        case .barre: return .sgfSecondary
        case .dance: return .sgfAccent
        }
    }
}

enum WorkoutIntensity: String, CaseIterable {
    case low, medium, high

    var displayName: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .low: return .sgfFollicular
        case .medium: return .sgfAccent
        case .high: return .sgfMenstrual
        }
    }
}

enum WorkoutCyclePhase: String, CaseIterable {
    case menstrual, follicular, ovulatory, luteal

    var displayName: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .menstrual: return .sgfMenstrual
        case .follicular: return .sgfFollicular
        case .ovulatory: return .sgfOvulatory
        case .luteal: return .sgfLuteal
        }
    }
}

struct WorkoutSummary: Identifiable {
    let id: String
    let title: String
    let category: WorkoutCategory
    let durationMinutes: Int
    let intensity: WorkoutIntensity
    let recommendedPhases: [WorkoutCyclePhase]

    static let placeholders: [WorkoutSummary] = [
        WorkoutSummary(id: "w1", title: "Gentle Flow Yoga", category: .yoga, durationMinutes: 20, intensity: .low, recommendedPhases: [.menstrual, .luteal]),
        WorkoutSummary(id: "w2", title: "Restorative Stretching", category: .stretching, durationMinutes: 15, intensity: .low, recommendedPhases: [.menstrual]),
        WorkoutSummary(id: "w3", title: "Mindful Walking", category: .cardio, durationMinutes: 20, intensity: .low, recommendedPhases: [.menstrual]),
        WorkoutSummary(id: "w4", title: "Energizing Pilates", category: .pilates, durationMinutes: 30, intensity: .medium, recommendedPhases: [.follicular, .luteal]),
        WorkoutSummary(id: "w5", title: "Dance Cardio Fun", category: .dance, durationMinutes: 25, intensity: .medium, recommendedPhases: [.follicular, .ovulatory]),
        WorkoutSummary(id: "w6", title: "Strength Foundations", category: .strength, durationMinutes: 35, intensity: .medium, recommendedPhases: [.follicular]),
        WorkoutSummary(id: "w7", title: "Power HIIT", category: .hiit, durationMinutes: 25, intensity: .high, recommendedPhases: [.ovulatory]),
        WorkoutSummary(id: "w8", title: "Athletic Strength", category: .strength, durationMinutes: 40, intensity: .high, recommendedPhases: [.ovulatory]),
        WorkoutSummary(id: "w9", title: "Cardio Blast", category: .cardio, durationMinutes: 30, intensity: .high, recommendedPhases: [.ovulatory, .follicular]),
        WorkoutSummary(id: "w10", title: "Barre Sculpt", category: .barre, durationMinutes: 35, intensity: .medium, recommendedPhases: [.luteal]),
        WorkoutSummary(id: "w11", title: "Stress Relief Yoga", category: .yoga, durationMinutes: 30, intensity: .low, recommendedPhases: [.luteal, .menstrual]),
        WorkoutSummary(id: "w12", title: "Upper Body Strength", category: .strength, durationMinutes: 30, intensity: .medium, recommendedPhases: [.luteal, .follicular]),
    ]
}

#Preview {
    WorkoutListView()
}
