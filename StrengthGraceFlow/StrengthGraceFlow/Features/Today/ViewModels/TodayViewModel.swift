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
    @Published var todayEnergyLevel: Int?
    @Published var isSavingEnergy = false

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

            // Show banner if not in menstrual phase and more than 20 days into cycle
            if let cycle = currentCycle {
                let isNotMenstruating = cycle.cycle.currentPhase != "menstrual"
                let isLateInCycle = cycle.cycle.cycleDay > 20
                shouldShowLogPeriodBanner = isNotMenstruating && isLateInCycle
            }
        } catch APIError.notFound {
            // No cycle data yet - show banner to encourage first log
            shouldShowLogPeriodBanner = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
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
