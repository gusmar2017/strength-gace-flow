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

            CycleCalendarView()
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

                    Text("Your cycle history and patterns")
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
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.sgfPrimary)

                        VStack(alignment: .leading, spacing: SGFSpacing.xs) {
                            Text("Your Profile")
                                .font(.sgfTitle3)
                                .foregroundColor(.sgfTextPrimary)

                            Text("Settings coming soon")
                                .font(.sgfCaption)
                                .foregroundColor(.sgfTextSecondary)
                        }
                        .padding(.leading, SGFSpacing.sm)
                    }
                    .padding(.vertical, SGFSpacing.sm)
                }
                .listRowBackground(Color.sgfSurface)

                Section {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.sgfSecondary)
                            Text("Sign Out")
                                .foregroundColor(.sgfTextPrimary)
                        }
                    }
                }
                .listRowBackground(Color.sgfSurface)

                #if DEBUG
                Section {
                    Button(action: {
                        authViewModel.resetToOnboarding()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.sgfSecondary)
                            Text("Reset to Onboarding")
                                .foregroundColor(.sgfTextPrimary)
                        }
                    }
                } header: {
                    Text("Developer Tools")
                        .foregroundColor(.sgfTextSecondary)
                }
                .listRowBackground(Color.sgfSurface)
                #endif
            }
            .scrollContentBackground(.hidden)
            .background(Color.sgfBackground)
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
