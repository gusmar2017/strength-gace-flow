//
//  MainTabView.swift
//  StrengthGraceFlow
//
//  Main tab navigation
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(0)

            WorkoutListView()
                .tabItem {
                    Label("Workouts", systemImage: "figure.run")
                }
                .tag(1)

            CalendarPlaceholderView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(2)

            ProfilePlaceholderView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.sgfPrimary)
    }
}

// MARK: - Placeholder Views

struct WorkoutsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgfBackground
                    .ignoresSafeArea()

                VStack(spacing: SGFSpacing.md) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 60))
                        .foregroundColor(.sgfTextTertiary)

                    Text("Workouts")
                        .font(.sgfTitle2)
                        .foregroundColor(.sgfTextPrimary)

                    Text("Coming in Phase 3")
                        .font(.sgfBody)
                        .foregroundColor(.sgfTextSecondary)
                }
            }
            .navigationTitle("Workouts")
        }
    }
}

struct CalendarPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgfBackground
                    .ignoresSafeArea()

                VStack(spacing: SGFSpacing.md) {
                    Image(systemName: "calendar")
                        .font(.system(size: 60))
                        .foregroundColor(.sgfTextTertiary)

                    Text("Cycle Calendar")
                        .font(.sgfTitle2)
                        .foregroundColor(.sgfTextPrimary)

                    Text("Track your cycle history")
                        .font(.sgfBody)
                        .foregroundColor(.sgfTextSecondary)
                }
            }
            .navigationTitle("Calendar")
        }
    }
}

struct ProfilePlaceholderView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgfBackground
                    .ignoresSafeArea()

                VStack(spacing: SGFSpacing.lg) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.sgfPrimary)

                    Text("Profile")
                        .font(.sgfTitle2)
                        .foregroundColor(.sgfTextPrimary)

                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .buttonStyle(SGFSecondaryButtonStyle())
                    .padding(.horizontal, SGFSpacing.xl)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
