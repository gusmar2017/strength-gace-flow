//
//  WelcomeView.swift
//  StrengthGraceFlow
//
//  Welcome screen with sign in/sign up options
//

import SwiftUI

struct WelcomeView: View {
    @State private var showSignIn = false
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.sgfBackground
                    .ignoresSafeArea()

                VStack(spacing: SGFSpacing.xl) {
                    Spacer()

                    // Logo and title
                    VStack(spacing: SGFSpacing.md) {
                        Image(systemName: "figure.yoga")
                            .font(.system(size: 80))
                            .foregroundColor(.sgfPrimary)

                        Text("Strength Grace Flow")
                            .font(.sgfLargeTitle)
                            .foregroundColor(.sgfTextPrimary)

                        Text("Workouts synced to your cycle")
                            .font(.sgfBody)
                            .foregroundColor(.sgfTextSecondary)
                    }

                    Spacer()

                    // Cycle phase indicators
                    HStack(spacing: SGFSpacing.md) {
                        PhaseIndicator(phase: "Menstrual", color: .sgfMenstrual)
                        PhaseIndicator(phase: "Follicular", color: .sgfFollicular)
                        PhaseIndicator(phase: "Ovulatory", color: .sgfOvulatory)
                        PhaseIndicator(phase: "Luteal", color: .sgfLuteal)
                    }
                    .padding(.horizontal, SGFSpacing.lg)

                    Spacer()

                    // Buttons
                    VStack(spacing: SGFSpacing.md) {
                        Button("Get Started") {
                            showSignUp = true
                        }
                        .buttonStyle(SGFPrimaryButtonStyle())

                        Button("I already have an account") {
                            showSignIn = true
                        }
                        .buttonStyle(SGFSecondaryButtonStyle())
                    }
                    .padding(.horizontal, SGFSpacing.lg)
                    .padding(.bottom, SGFSpacing.xl)
                }
            }
            .navigationDestination(isPresented: $showSignIn) {
                SignInView()
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

struct PhaseIndicator: View {
    let phase: String
    let color: Color

    var body: some View {
        VStack(spacing: SGFSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(phase)
                .font(.sgfCaption)
                .foregroundColor(.sgfTextSecondary)
        }
    }
}

#Preview {
    WelcomeView()
}
