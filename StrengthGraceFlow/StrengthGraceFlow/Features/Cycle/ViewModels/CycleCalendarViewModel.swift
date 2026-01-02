//
//  CycleCalendarViewModel.swift
//  StrengthGraceFlow
//
//  View model for cycle calendar management
//

import Foundation

@MainActor
class CycleCalendarViewModel: ObservableObject {
    @Published var cycleDates: [Date] = []
    @Published var cycleHistory: [CycleData] = []
    @Published var predictions: [PhasePrediction] = []
    @Published var nextPeriodDate: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    func loadCalendarData() async {
        isLoading = true
        errorMessage = nil

        // First check if user profile exists
        do {
            let profileResponse = try await apiService.getUserProfile()
            _ = profileResponse.user.displayName
        } catch {
            errorMessage = "Please complete onboarding first"
            isLoading = false
            return
        }

        // Load cycle history (essential)
        do {
            let historyResponse = try await apiService.getCycleHistory(limit: 24)
            cycleHistory = historyResponse.cycles
            cycleDates = historyResponse.cycles.map { $0.startDate }
        } catch {
            errorMessage = "Failed to load cycle history: \(error.localizedDescription)"
        }

        // Load predictions (optional - may fail if insufficient data)
        do {
            let predictionsResponse = try await apiService.getCyclePredictions(days: 90)
            predictions = predictionsResponse.predictions
            nextPeriodDate = predictionsResponse.nextPeriodStart
        } catch {
            // Don't set errorMessage - predictions are optional
        }

        isLoading = false
    }

    func logCycleStart(date: Date) async {
        isLoading = true
        errorMessage = nil

        do {
            // Normalize to midnight UTC (backend requires exact dates)
            let normalizedDate = dateToMidnightUTC(date)
            let cycleInfo = try await apiService.logPeriod(startDate: normalizedDate, notes: nil)

            // Schedule period start reminder notifications
            do {
                let history = try await apiService.getCycleHistory(limit: 1)
                if let cycleId = history.cycles.first?.id {
                    await NotificationManager.shared.schedulePeriodStartNotifications(
                        periodStartDate: normalizedDate,
                        avgCycleLength: cycleInfo.averageCycleLength,
                        cycleId: cycleId
                    )
                }
            } catch {
                // Notification scheduling is non-critical, don't fail the whole operation
                print("Failed to schedule notifications: \(error.localizedDescription)")
            }

            await loadCalendarData() // Reload to update calendar
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func dateToMidnightUTC(_ date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
}
