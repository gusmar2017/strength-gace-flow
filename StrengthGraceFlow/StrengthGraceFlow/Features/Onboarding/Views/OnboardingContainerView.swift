//
//  OnboardingContainerView.swift
//  StrengthGraceFlow
//
//  Container for the onboarding flow
//

import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep = 0

    @State private var displayName = ""
    @State private var selectedGoals: Set<FitnessGoal> = []
    @State private var selectedLevel: FitnessLevel?
    @State private var averageCycleLength = 28
    @State private var averagePeriodLength = 5

    let totalSteps = 4

    var body: some View {
        ZStack {
            Color.sgfBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                ProgressBarView(current: currentStep, total: totalSteps)
                    .padding(.horizontal, SGFSpacing.lg)
                    .padding(.top, SGFSpacing.md)

                // Content
                TabView(selection: $currentStep) {
                    OnboardingNameView(displayName: $displayName, onNext: nextStep)
                        .tag(0)

                    OnboardingGoalsView(selectedGoals: $selectedGoals, onNext: nextStep)
                        .tag(1)

                    OnboardingLevelView(selectedLevel: $selectedLevel, onNext: nextStep)
                        .tag(2)

                    OnboardingCycleView(
                        cycleLength: $averageCycleLength,
                        periodLength: $averagePeriodLength,
                        onComplete: completeOnboarding
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
        }
    }

    private func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    private func completeOnboarding() {
        // TODO: Save profile to backend
        authViewModel.completeOnboarding()
    }
}

// MARK: - Progress Bar

struct ProgressBarView: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: SGFSpacing.xs) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.sgfPrimary : Color.sgfTextTertiary.opacity(0.3))
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Onboarding Name View

struct OnboardingNameView: View {
    @Binding var displayName: String
    let onNext: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: SGFSpacing.xl) {
            Spacer()

            VStack(spacing: SGFSpacing.md) {
                Text("What should we call you?")
                    .font(.sgfTitle)
                    .foregroundColor(.sgfTextPrimary)
                    .multilineTextAlignment(.center)

                Text("This is how we'll greet you in the app")
                    .font(.sgfBody)
                    .foregroundColor(.sgfTextSecondary)
            }

            TextField("Your name", text: $displayName)
                .textFieldStyle(SGFTextFieldStyle())
                .padding(.horizontal, SGFSpacing.lg)
                .focused($isFocused)
                .submitLabel(.continue)
                .onSubmit {
                    if !displayName.isEmpty { onNext() }
                }

            Spacer()

            Button("Continue") {
                onNext()
            }
            .buttonStyle(SGFPrimaryButtonStyle(isDisabled: displayName.isEmpty))
            .disabled(displayName.isEmpty)
            .padding(.horizontal, SGFSpacing.lg)
            .padding(.bottom, SGFSpacing.xl)
        }
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - Onboarding Goals View

enum FitnessGoal: String, CaseIterable {
    case strength = "Build Strength"
    case flexibility = "Improve Flexibility"
    case energy = "Boost Energy"
    case stress = "Reduce Stress"
    case weight = "Manage Weight"
    case endurance = "Build Endurance"
}

struct OnboardingGoalsView: View {
    @Binding var selectedGoals: Set<FitnessGoal>
    let onNext: () -> Void

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: SGFSpacing.xl) {
            VStack(spacing: SGFSpacing.md) {
                Text("What are your goals?")
                    .font(.sgfTitle)
                    .foregroundColor(.sgfTextPrimary)

                Text("Select all that apply")
                    .font(.sgfBody)
                    .foregroundColor(.sgfTextSecondary)
            }
            .padding(.top, SGFSpacing.xl)

            LazyVGrid(columns: columns, spacing: SGFSpacing.md) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: selectedGoals.contains(goal)
                    ) {
                        if selectedGoals.contains(goal) {
                            selectedGoals.remove(goal)
                        } else {
                            selectedGoals.insert(goal)
                        }
                    }
                }
            }
            .padding(.horizontal, SGFSpacing.lg)

            Spacer()

            Button("Continue") {
                onNext()
            }
            .buttonStyle(SGFPrimaryButtonStyle(isDisabled: selectedGoals.isEmpty))
            .disabled(selectedGoals.isEmpty)
            .padding(.horizontal, SGFSpacing.lg)
            .padding(.bottom, SGFSpacing.xl)
        }
    }
}

struct GoalCard: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let action: () -> Void

    var icon: String {
        switch goal {
        case .strength: return "figure.strengthtraining.traditional"
        case .flexibility: return "figure.yoga"
        case .energy: return "bolt.fill"
        case .stress: return "leaf.fill"
        case .weight: return "scalemass.fill"
        case .endurance: return "heart.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: SGFSpacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .sgfPrimary)

                Text(goal.rawValue)
                    .font(.sgfSubheadline)
                    .foregroundColor(isSelected ? .white : .sgfTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SGFSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .fill(isSelected ? Color.sgfPrimary : Color.sgfSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .stroke(isSelected ? Color.sgfPrimary : Color.sgfTextTertiary.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Onboarding Level View

enum FitnessLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct OnboardingLevelView: View {
    @Binding var selectedLevel: FitnessLevel?
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: SGFSpacing.xl) {
            VStack(spacing: SGFSpacing.md) {
                Text("What's your fitness level?")
                    .font(.sgfTitle)
                    .foregroundColor(.sgfTextPrimary)

                Text("We'll personalize workouts for you")
                    .font(.sgfBody)
                    .foregroundColor(.sgfTextSecondary)
            }
            .padding(.top, SGFSpacing.xl)

            VStack(spacing: SGFSpacing.md) {
                ForEach(FitnessLevel.allCases, id: \.self) { level in
                    LevelCard(
                        level: level,
                        isSelected: selectedLevel == level
                    ) {
                        selectedLevel = level
                    }
                }
            }
            .padding(.horizontal, SGFSpacing.lg)

            Spacer()

            Button("Continue") {
                onNext()
            }
            .buttonStyle(SGFPrimaryButtonStyle(isDisabled: selectedLevel == nil))
            .disabled(selectedLevel == nil)
            .padding(.horizontal, SGFSpacing.lg)
            .padding(.bottom, SGFSpacing.xl)
        }
    }
}

struct LevelCard: View {
    let level: FitnessLevel
    let isSelected: Bool
    let action: () -> Void

    var description: String {
        switch level {
        case .beginner:
            return "New to fitness or getting back into it"
        case .intermediate:
            return "Exercise regularly, comfortable with most movements"
        case .advanced:
            return "Experienced athlete, ready for challenges"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: SGFSpacing.xs) {
                    Text(level.rawValue)
                        .font(.sgfHeadline)
                        .foregroundColor(isSelected ? .white : .sgfTextPrimary)

                    Text(description)
                        .font(.sgfSubheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .sgfTextSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(SGFSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .fill(isSelected ? Color.sgfPrimary : Color.sgfSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .stroke(isSelected ? Color.sgfPrimary : Color.sgfTextTertiary.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Onboarding Cycle View

struct OnboardingCycleView: View {
    @Binding var cycleLength: Int
    @Binding var periodLength: Int
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: SGFSpacing.xl) {
            VStack(spacing: SGFSpacing.md) {
                Text("Tell us about your cycle")
                    .font(.sgfTitle)
                    .foregroundColor(.sgfTextPrimary)

                Text("This helps us recommend the right workouts")
                    .font(.sgfBody)
                    .foregroundColor(.sgfTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, SGFSpacing.xl)

            VStack(spacing: SGFSpacing.lg) {
                // Cycle length
                VStack(spacing: SGFSpacing.sm) {
                    Text("Average cycle length")
                        .font(.sgfSubheadline)
                        .foregroundColor(.sgfTextSecondary)

                    HStack {
                        Button {
                            if cycleLength > 21 { cycleLength -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.sgfPrimary)
                        }

                        Text("\(cycleLength) days")
                            .font(.sgfTitle2)
                            .foregroundColor(.sgfTextPrimary)
                            .frame(width: 100)

                        Button {
                            if cycleLength < 35 { cycleLength += 1 }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.sgfPrimary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                        .fill(Color.sgfSurface)
                )

                // Period length
                VStack(spacing: SGFSpacing.sm) {
                    Text("Average period length")
                        .font(.sgfSubheadline)
                        .foregroundColor(.sgfTextSecondary)

                    HStack {
                        Button {
                            if periodLength > 3 { periodLength -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.sgfSecondary)
                        }

                        Text("\(periodLength) days")
                            .font(.sgfTitle2)
                            .foregroundColor(.sgfTextPrimary)
                            .frame(width: 100)

                        Button {
                            if periodLength < 7 { periodLength += 1 }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.sgfSecondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                        .fill(Color.sgfSurface)
                )
            }
            .padding(.horizontal, SGFSpacing.lg)

            Text("Don't worry, you can update this later")
                .font(.sgfCaption)
                .foregroundColor(.sgfTextTertiary)

            Spacer()

            Button("Start My Journey") {
                onComplete()
            }
            .buttonStyle(SGFPrimaryButtonStyle())
            .padding(.horizontal, SGFSpacing.lg)
            .padding(.bottom, SGFSpacing.xl)
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AuthViewModel())
}
