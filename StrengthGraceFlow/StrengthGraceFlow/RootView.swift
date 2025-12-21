//
//  RootView.swift
//  StrengthGraceFlow
//
//  Root navigation based on authentication state
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .loading:
                LoadingView()
            case .unauthenticated:
                WelcomeView()
            case .onboarding:
                OnboardingContainerView()
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.authState)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.sgfBackground
                .ignoresSafeArea()

            VStack(spacing: SGFSpacing.md) {
                Image(systemName: "figure.run")
                    .font(.system(size: 60))
                    .foregroundColor(.sgfPrimary)

                ProgressView()
                    .tint(.sgfPrimary)
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}
