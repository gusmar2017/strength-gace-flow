//
//  CycleHistoryViewModel.swift
//  StrengthGraceFlow
//
//  View model for cycle history management
//

import Foundation

@MainActor
class CycleHistoryViewModel: ObservableObject {
    @Published var cycles: [CycleData] = []
    @Published var averageCycleLength: Int = 28
    @Published var totalCyclesLogged: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadHistory() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIService.shared.getCycleHistory(limit: 12)
            cycles = response.cycles
            averageCycleLength = response.averageCycleLength
            totalCyclesLogged = response.totalCyclesLogged
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logPeriod(date: Date, notes: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await APIService.shared.logPeriod(
                startDate: date,
                notes: notes?.isEmpty == false ? notes : nil
            )
            await loadHistory() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteCycle(_ cycleId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await APIService.shared.deleteCycleEntry(cycleId: cycleId)
            await loadHistory() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
