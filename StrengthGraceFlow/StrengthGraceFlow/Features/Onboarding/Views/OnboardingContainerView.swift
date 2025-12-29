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
    @State private var cycleDates: [Date] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

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
                        cycleDates: $cycleDates,
                        isLoading: $isLoading,
                        errorMessage: $errorMessage,
                        onComplete: completeOnboarding
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }

    private func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut) {
                currentStep += 1
            }
        }
    }

    private func completeOnboarding() {
        Task {
            isLoading = true
            errorMessage = nil

            #if DEBUG
            // For developer testing, just complete onboarding without API call
            await MainActor.run {
                authViewModel.completeOnboarding()
                isLoading = false
            }
            #else
            do {
                // Calculate averages from dates if provided
                let (avgCycle, avgPeriod) = calculateAveragesFromDates(cycleDates)

                // Map FitnessGoal to backend format
                let goalStrings = selectedGoals.map { goal in
                    switch goal {
                    case .strength: return "build_strength"
                    case .flexibility: return "improve_flexibility"
                    case .energy: return "hormone_balance"
                    case .stress: return "reduce_stress"
                    case .weight: return "consistency"
                    case .endurance: return "build_strength"
                    }
                }

                // Try to update profile first (for existing users during developer reset)
                // If that fails, create a new profile (for new users)
                do {
                    let updateRequest = UpdateUserRequest(
                        displayName: displayName,
                        fitnessLevel: selectedLevel?.rawValue.lowercased(),
                        goals: goalStrings,
                        averageCycleLength: avgCycle,
                        averagePeriodLength: avgPeriod,
                        cycleTrackingEnabled: true,
                        notificationsEnabled: true
                    )
                    _ = try await APIService.shared.updateUserProfile(data: updateRequest)
                } catch let error as APIError {
                    // If update fails with 404 (user profile doesn't exist), create it
                    if case .notFound = error {
                        let createRequest = CreateUserRequest(
                            displayName: displayName,
                            fitnessLevel: selectedLevel?.rawValue.lowercased(),
                            goals: goalStrings,
                            averageCycleLength: avgCycle,
                            averagePeriodLength: avgPeriod,
                            cycleTrackingEnabled: true,
                            notificationsEnabled: true,
                            initialCycleDates: nil
                        )
                        _ = try await APIService.shared.createUserProfile(data: createRequest)
                    } else {
                        throw error
                    }
                }

                // Complete onboarding in auth view model
                await MainActor.run {
                    authViewModel.completeOnboarding()
                    isLoading = false
                }
            } catch let error as APIError {
                await MainActor.run {
                    errorMessage = error.errorDescription
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Something went wrong. Please try again."
                    isLoading = false
                }
            }
            #endif
        }
    }

    private func calculateAveragesFromDates(_ dates: [Date]) -> (cycle: Int, period: Int) {
        guard dates.count >= 2 else {
            return (28, 5) // defaults
        }

        let sorted = dates.sorted()
        var cycleLengths: [Int] = []

        for i in 0..<(sorted.count - 1) {
            let days = Calendar.current.dateComponents([.day], from: sorted[i], to: sorted[i+1]).day ?? 0
            cycleLengths.append(days)
        }

        let avgCycle = cycleLengths.isEmpty ? 28 : cycleLengths.reduce(0, +) / cycleLengths.count
        return (avgCycle, 5) // period length still default for now
    }
}

// MARK: - Progress Bar

struct ProgressBarView: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: SGFSpacing.xs) {
            ForEach(0..<max(1, total), id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.sgfPrimary : Color.sgfTextTertiary.opacity(0.3))
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .frame(height: 4)
        .fixedSize(horizontal: false, vertical: true)
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
                    if !displayName.isEmpty {
                        isFocused = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onNext()
                        }
                    }
                }

            Spacer()

            Button("Continue") {
                isFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onNext()
                }
            }
            .buttonStyle(SGFPrimaryButtonStyle(isDisabled: displayName.isEmpty))
            .disabled(displayName.isEmpty)
            .padding(.horizontal, SGFSpacing.lg)
            .padding(.bottom, SGFSpacing.xl)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
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
                Text("What brings you here?")
                    .font(.sgfTitle)
                    .foregroundColor(.sgfTextPrimary)

                Text("Choose what resonates with you")
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
                Text("How would you describe your current practice?")
                    .font(.sgfTitle)
                    .foregroundColor(.sgfTextPrimary)

                Text("We'll suggest movement that feels right for you")
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
    @Binding var cycleDates: [Date]
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let onComplete: () -> Void

    @State private var showingDatePicker = false
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: SGFSpacing.xl) {
            VStack(spacing: SGFSpacing.md) {
                Text("When did your last few cycles begin?")
                    .font(.sgfTitle)
                    .foregroundColor(.sgfTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Add 1-3 recent dates to help us understand your rhythm")
                    .font(.sgfBody)
                    .foregroundColor(.sgfTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, SGFSpacing.xl)

            // Date list
            VStack(spacing: SGFSpacing.sm) {
                ForEach(cycleDates.sorted(by: >), id: \.self) { date in
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.sgfPrimary)
                        Text(date, style: .date)
                            .font(.sgfBody)
                            .foregroundColor(.sgfTextPrimary)
                        Spacer()
                        Button {
                            cycleDates.removeAll { $0 == date }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.sgfTextTertiary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                            .fill(Color.sgfSurface)
                    )
                }

                // Add date button
                if cycleDates.count < 3 {
                    Button {
                        showingDatePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.sgfPrimary)
                            Text("Add cycle start date")
                                .font(.sgfBody)
                                .foregroundColor(.sgfPrimary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                                .stroke(Color.sgfPrimary, style: StrokeStyle(lineWidth: 2, dash: [5]))
                        )
                    }
                }
            }
            .padding(.horizontal, SGFSpacing.lg)

            if cycleDates.isEmpty {
                VStack(spacing: SGFSpacing.sm) {
                    Text("Don't remember exact dates?")
                        .font(.sgfCaption)
                        .foregroundColor(.sgfTextTertiary)
                    Text("You can skip this and begin tracking whenever you're ready")
                        .font(.sgfCaption)
                        .foregroundColor(.sgfTextTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, SGFSpacing.xl)
            }

            Spacer()

            // Error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.sgfCaption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SGFSpacing.lg)
            }

            Button(cycleDates.isEmpty ? "Skip for Now" : "Continue") {
                onComplete()
            }
            .buttonStyle(SGFPrimaryButtonStyle(isDisabled: isLoading))
            .disabled(isLoading)
            .padding(.horizontal, SGFSpacing.lg)
            .padding(.bottom, SGFSpacing.xl)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate) { date in
                if !cycleDates.contains(date) && cycleDates.count < 3 {
                    cycleDates.append(date)
                }
                showingDatePicker = false
            }
        }
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
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
            .navigationTitle("Add Start Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(selectedDate)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AuthViewModel())
}
