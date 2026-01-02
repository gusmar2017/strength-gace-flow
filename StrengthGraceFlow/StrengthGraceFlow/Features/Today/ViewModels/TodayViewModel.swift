//
//  TodayViewModel.swift
//  StrengthGraceFlow
//
//  View model for Today screen with cycle data
//

import Foundation
import SwiftUI

@MainActor
class TodayViewModel: ObservableObject {
    @Published var currentCycle: CycleInfoResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldShowLogPeriodBanner = false
    @Published var shouldShowEndPeriodButton = false
    @Published var currentCycleId: String?
    @Published var todayEnergyLevel: Int?
    @Published var isSavingEnergy = false

    var periodStartDate: Date {
        return currentCycle?.lastPeriodStart ?? Date()
    }

    init() {
        Task {
            await loadCycleInfo()
            await loadTodayEnergy()
        }
    }

    func loadCycleInfo() async {
        isLoading = true
        errorMessage = nil

        do {
            currentCycle = try await APIService.shared.getCurrentCycle()

            // Intelligent cycle start prompting based on user's cycle patterns
            if let cycle = currentCycle {
                let isNotMenstruating = cycle.cycle.currentPhase != "menstrual"

                // Calculate days until expected period start
                let daysUntilExpected = cycle.averageCycleLength - cycle.cycle.cycleDay

                // Get cycle history to determine variability and check for period end button
                do {
                    let history = try await APIService.shared.getCycleHistory(limit: 12)
                    let cycleLengths = history.cycles.compactMap { $0.cycleLength }

                    // Calculate dynamic window size based on cycle variability
                    let windowSize = calculateCycleVariability(cycleLengths: cycleLengths)

                    // Show banner if within the expected window for period start
                    let withinExpectedWindow = daysUntilExpected >= -windowSize && daysUntilExpected <= windowSize
                    shouldShowLogPeriodBanner = isNotMenstruating && withinExpectedWindow

                    // Check if we should show the "End Period" button
                    if let currentCycleData = history.cycles.first {
                        currentCycleId = currentCycleData.id
                        let hasPeriodEndDate = currentCycleData.periodEndDate != nil

                        shouldShowEndPeriodButton = NotificationManager.shared.shouldShowPeriodEndPrompt(
                            for: currentCycleData.id
                        ) && cycle.cycle.currentPhase == "menstrual"
                            && !hasPeriodEndDate
                            && isDatePastExpectedEnd(
                                periodStart: cycle.lastPeriodStart,
                                avgPeriodLength: cycle.averagePeriodLength
                            )
                    }
                } catch {
                    // Fallback to simple logic if history fetch fails
                    let isLateInCycle = cycle.cycle.cycleDay > 20
                    shouldShowLogPeriodBanner = isNotMenstruating && isLateInCycle
                    shouldShowEndPeriodButton = false
                }
            }
        } catch APIError.notFound {
            // No cycle data yet - show banner to encourage first log
            shouldShowLogPeriodBanner = true
            shouldShowEndPeriodButton = false
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Check if today is past the expected period end date + 1 day
    private func isDatePastExpectedEnd(periodStart: Date, avgPeriodLength: Int) -> Bool {
        let calendar = Calendar.current
        guard let expectedEndDate = calendar.date(byAdding: .day, value: avgPeriodLength, to: periodStart),
              let promptDate = calendar.date(byAdding: .day, value: 1, to: expectedEndDate) else {
            return false
        }

        let today = calendar.startOfDay(for: Date())
        let prompt = calendar.startOfDay(for: promptDate)

        return today >= prompt
    }

    /// Calculates the window size for period prompting based on cycle variability
    /// - Parameter cycleLengths: Array of cycle lengths from history
    /// - Returns: Window size in days (±2 to ±5 days)
    private func calculateCycleVariability(cycleLengths: [Int]) -> Int {
        // Default for first cycle or no data
        guard !cycleLengths.isEmpty else { return 3 }

        // Return default for only one cycle
        if cycleLengths.count == 1 {
            return 3
        }

        // Calculate standard deviation for 2+ cycles
        let mean = Double(cycleLengths.reduce(0, +)) / Double(cycleLengths.count)
        let variance = cycleLengths.map { pow(Double($0) - mean, 2) }.reduce(0, +) / Double(cycleLengths.count)
        let standardDeviation = sqrt(variance)

        // Return window size based on regularity
        switch standardDeviation {
        case ...1.0:
            return 2  // Very regular: ±2 days
        case 1.0...2.0:
            return 3  // Moderately regular: ±3 days
        case 2.0...4.0:
            return 4  // Somewhat irregular: ±4 days
        default:
            return 5  // Very irregular: ±5 days
        }
    }

    func logPeriod(date: Date, notes: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            currentCycle = try await APIService.shared.logPeriod(
                startDate: date,
                notes: notes?.isEmpty == false ? notes : nil
            )
            shouldShowLogPeriodBanner = false

            // Schedule period end notifications
            if let cycle = currentCycle {
                // Get the current cycle ID to schedule notifications
                do {
                    let history = try await APIService.shared.getCycleHistory(limit: 1)
                    if let cycleId = history.cycles.first?.id {
                        await NotificationManager.shared.schedulePeriodEndNotifications(
                            periodStartDate: date,
                            avgPeriodLength: cycle.averagePeriodLength,
                            cycleId: cycleId
                        )
                    }
                } catch {
                    // Notification scheduling is non-critical, don't fail the whole operation
                    print("Failed to schedule notifications: \(error.localizedDescription)")
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func endPeriod(date: Date) async {
        isLoading = true
        errorMessage = nil

        do {
            currentCycle = try await APIService.shared.endCurrentPeriod(endDate: date)

            // Increment attempt count and cancel notifications
            if let cycleId = currentCycleId {
                NotificationManager.shared.incrementAttemptCount(for: cycleId)
                await NotificationManager.shared.cancelPeriodEndNotifications()
            }

            // Hide the button
            shouldShowEndPeriodButton = false

            // Reload cycle info to update UI
            await loadCycleInfo()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadTodayEnergy() async {
        do {
            let response = try await APIService.shared.getTodayEnergy()
            todayEnergyLevel = response.energy.score
        } catch APIError.notFound {
            // No energy logged for today - that's okay
            todayEnergyLevel = nil
        } catch {
            // Silently fail for energy loading - not critical
            todayEnergyLevel = nil
        }
    }

    func logEnergy(score: Int) async {
        isSavingEnergy = true

        do {
            let response = try await APIService.shared.logEnergy(
                date: Date(),
                score: score,
                notes: nil
            )
            todayEnergyLevel = response.energy.score
        } catch {
            errorMessage = error.localizedDescription
        }

        isSavingEnergy = false
    }
}
