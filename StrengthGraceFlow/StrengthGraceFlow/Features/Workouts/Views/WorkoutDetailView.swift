//
//  WorkoutDetailView.swift
//  StrengthGraceFlow
//
//  Workout detail with video player placeholder
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutSummary
    @Environment(\.dismiss) var dismiss
    @State private var isPlaying = false
    @State private var showCompletionSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Video player placeholder
                    videoPlayerPlaceholder

                    // Content
                    VStack(alignment: .leading, spacing: SGFSpacing.lg) {
                        // Title and meta
                        headerSection

                        Divider()

                        // Description
                        descriptionSection

                        // Recommended phases
                        phasesSection

                        // Equipment (placeholder)
                        equipmentSection

                        Spacer(minLength: 100)
                    }
                    .padding(SGFSpacing.lg)
                }
            }
            .background(Color.sgfBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.sgfTextSecondary)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                startButton
            }
            .sheet(isPresented: $showCompletionSheet) {
                WorkoutCompletionView(workout: workout)
            }
        }
    }

    var videoPlayerPlaceholder: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [workout.category.color.opacity(0.3), workout.category.color.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .aspectRatio(16/9, contentMode: .fit)

            VStack(spacing: SGFSpacing.md) {
                Image(systemName: workout.category.icon)
                    .font(.system(size: 60))
                    .foregroundColor(workout.category.color)

                if !isPlaying {
                    Button {
                        isPlaying = true
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    }
                } else {
                    VStack(spacing: SGFSpacing.sm) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)

                        Text("Video coming soon")
                            .font(.sgfSubheadline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.sm) {
            // Category badge
            Text(workout.category.displayName.uppercased())
                .font(.sgfCaption)
                .fontWeight(.bold)
                .foregroundColor(workout.category.color)

            // Title
            Text(workout.title)
                .font(.sgfTitle)
                .foregroundColor(.sgfTextPrimary)

            // Meta info
            HStack(spacing: SGFSpacing.lg) {
                Label("\(workout.durationMinutes) min", systemImage: "clock")
                Label(workout.intensity.displayName, systemImage: "flame")
                    .foregroundColor(workout.intensity.color)
                Label("~150 cal", systemImage: "bolt")
            }
            .font(.sgfSubheadline)
            .foregroundColor(.sgfTextSecondary)
        }
    }

    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.sm) {
            Text("About this workout")
                .font(.sgfHeadline)
                .foregroundColor(.sgfTextPrimary)

            Text(workoutDescription)
                .font(.sgfBody)
                .foregroundColor(.sgfTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var workoutDescription: String {
        switch workout.category {
        case .yoga:
            return "Flow through gentle poses designed to stretch and strengthen your body while calming your mind. Perfect for any time you need to reset."
        case .strength:
            return "Build functional strength with compound movements. Focus on proper form and controlled movements for maximum results."
        case .cardio:
            return "Get your heart pumping with this energizing cardio session. Modified movements available for all fitness levels."
        case .hiit:
            return "High-intensity intervals designed to maximize calorie burn and boost your metabolism. Push yourself!"
        case .pilates:
            return "Core-focused movements to build strength and stability. Emphasis on controlled, precise movements."
        case .stretching:
            return "Full body stretching routine to improve flexibility and release tension. Great for rest days."
        case .barre:
            return "Low-impact, high-results workout combining ballet, yoga, and Pilates movements."
        case .dance:
            return "Fun, energizing dance cardio with easy-to-follow choreography. No dance experience needed!"
        }
    }

    var phasesSection: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.sm) {
            Text("Best for")
                .font(.sgfHeadline)
                .foregroundColor(.sgfTextPrimary)

            HStack(spacing: SGFSpacing.sm) {
                ForEach(workout.recommendedPhases, id: \.self) { phase in
                    HStack(spacing: SGFSpacing.xs) {
                        Circle()
                            .fill(phase.color)
                            .frame(width: 8, height: 8)
                        Text(phase.displayName)
                    }
                    .font(.sgfSubheadline)
                    .foregroundColor(.sgfTextSecondary)
                    .padding(.horizontal, SGFSpacing.md)
                    .padding(.vertical, SGFSpacing.sm)
                    .background(
                        Capsule()
                            .fill(phase.color.opacity(0.15))
                    )
                }
            }
        }
    }

    var equipmentSection: some View {
        VStack(alignment: .leading, spacing: SGFSpacing.sm) {
            Text("Equipment needed")
                .font(.sgfHeadline)
                .foregroundColor(.sgfTextPrimary)

            HStack(spacing: SGFSpacing.sm) {
                EquipmentChip(name: "Yoga mat", icon: "rectangle.portrait")

                if workout.category == .strength {
                    EquipmentChip(name: "Dumbbells", icon: "dumbbell")
                }
            }
        }
    }

    var startButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                showCompletionSheet = true
            } label: {
                Text("Start Workout")
                    .font(.sgfHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SGFSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                            .fill(Color.sgfPrimary)
                    )
            }
            .padding(SGFSpacing.lg)
            .background(Color.sgfBackground)
        }
    }
}

struct EquipmentChip: View {
    let name: String
    let icon: String

    var body: some View {
        HStack(spacing: SGFSpacing.xs) {
            Image(systemName: icon)
            Text(name)
        }
        .font(.sgfSubheadline)
        .foregroundColor(.sgfTextSecondary)
        .padding(.horizontal, SGFSpacing.md)
        .padding(.vertical, SGFSpacing.sm)
        .background(
            Capsule()
                .stroke(Color.sgfTextTertiary.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Completion View

struct WorkoutCompletionView: View {
    let workout: WorkoutSummary
    @Environment(\.dismiss) var dismiss
    @State private var rating = 0
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: SGFSpacing.xl) {
                Spacer()

                // Success animation placeholder
                VStack(spacing: SGFSpacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.sgfSuccess)

                    Text("Great job!")
                        .font(.sgfLargeTitle)
                        .foregroundColor(.sgfTextPrimary)

                    Text("You completed \(workout.title)")
                        .font(.sgfBody)
                        .foregroundColor(.sgfTextSecondary)
                }

                // Stats
                HStack(spacing: SGFSpacing.xl) {
                    StatBubble(value: "\(workout.durationMinutes)", label: "Minutes")
                    StatBubble(value: "~150", label: "Calories")
                }

                // Rating
                VStack(spacing: SGFSpacing.sm) {
                    Text("How was it?")
                        .font(.sgfHeadline)
                        .foregroundColor(.sgfTextPrimary)

                    HStack(spacing: SGFSpacing.md) {
                        ForEach(1...5, id: \.self) { index in
                            Button {
                                rating = index
                            } label: {
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .font(.title)
                                    .foregroundColor(index <= rating ? .sgfAccent : .sgfTextTertiary)
                            }
                        }
                    }
                }

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(SGFPrimaryButtonStyle())
                .padding(.horizontal, SGFSpacing.lg)
                .padding(.bottom, SGFSpacing.xl)
            }
            .background(Color.sgfBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(.sgfTextSecondary)
                }
            }
        }
    }
}

struct StatBubble: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: SGFSpacing.xs) {
            Text(value)
                .font(.sgfTitle)
                .foregroundColor(.sgfPrimary)
            Text(label)
                .font(.sgfCaption)
                .foregroundColor(.sgfTextSecondary)
        }
        .padding(SGFSpacing.lg)
        .background(
            Circle()
                .fill(Color.sgfPrimary.opacity(0.1))
        )
    }
}

#Preview {
    WorkoutDetailView(workout: WorkoutSummary.placeholders[0])
}
