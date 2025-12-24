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

    init() {
        Task {
            await loadCycleInfo()
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
}
