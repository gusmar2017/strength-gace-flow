//
//  CycleHistoryView.swift
//  StrengthGraceFlow
//
//  View and edit cycle history
//

import SwiftUI

struct CycleHistoryView: View {
    @StateObject private var viewModel = CycleHistoryViewModel()
    @State private var showingAddPeriod = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgfBackground.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.cycles.isEmpty {
                    EmptyHistoryView {
                        showingAddPeriod = true
                    }
                } else {
                    ScrollView {
                        VStack(spacing: SGFSpacing.lg) {
                            // Stats card
                            StatsCard(
                                averageCycle: viewModel.averageCycleLength,
                                totalCycles: viewModel.totalCyclesLogged
                            )
                            .padding(.horizontal, SGFSpacing.lg)

                            // Cycle list
                            VStack(spacing: SGFSpacing.md) {
                                ForEach(viewModel.cycles, id: \.id) { cycle in
                                    CycleHistoryRow(cycle: cycle) { cycleId in
                                        Task {
                                            await viewModel.deleteCycle(cycleId)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, SGFSpacing.lg)
                        }
                        .padding(.vertical, SGFSpacing.md)
                    }
                }
            }
            .navigationTitle("Cycle History")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPeriod = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPeriod) {
                AddPeriodSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.loadHistory()
            }
        }
    }
}

// MARK: - Stats Card

struct StatsCard: View {
    let averageCycle: Int
    let totalCycles: Int

    var body: some View {
        HStack(spacing: SGFSpacing.xl) {
            VStack(spacing: SGFSpacing.xs) {
                Text("\(averageCycle)")
                    .font(.sgfLargeTitle)
                    .foregroundColor(.sgfPrimary)
                Text("Avg Cycle")
                    .font(.sgfCaption)
                    .foregroundColor(.sgfTextSecondary)
            }

            Divider()

            VStack(spacing: SGFSpacing.xs) {
                Text("\(totalCycles)")
                    .font(.sgfLargeTitle)
                    .foregroundColor(.sgfSecondary)
                Text("Cycles Logged")
                    .font(.sgfCaption)
                    .foregroundColor(.sgfTextSecondary)
            }
        }
        .padding(SGFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                .fill(Color.sgfSurface)
        )
    }
}

// MARK: - Cycle History Row

struct CycleHistoryRow: View {
    let cycle: CycleData
    let onDelete: (String) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: SGFSpacing.xs) {
                Text(cycle.startDate, style: .date)
                    .font(.sgfHeadline)
                    .foregroundColor(.sgfTextPrimary)

                if let length = cycle.cycleLength {
                    Text("\(length) days")
                        .font(.sgfSubheadline)
                        .foregroundColor(.sgfTextSecondary)
                } else {
                    Text("Current cycle")
                        .font(.sgfSubheadline)
                        .foregroundColor(.sgfPrimary)
                }

                if let notes = cycle.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.sgfCaption)
                        .foregroundColor(.sgfTextTertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if cycle.cycleLength != nil {
                Menu {
                    Button(role: .destructive) {
                        onDelete(cycle.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.sgfTextTertiary)
                }
            }
        }
        .padding(SGFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                .fill(Color.sgfSurface)
        )
    }
}

// MARK: - Empty History View

struct EmptyHistoryView: View {
    let onAddFirst: () -> Void

    var body: some View {
        VStack(spacing: SGFSpacing.lg) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.sgfTextTertiary)

            Text("No Cycle History Yet")
                .font(.sgfTitle2)
                .foregroundColor(.sgfTextPrimary)

            Text("Start tracking by logging your period start dates")
                .font(.sgfBody)
                .foregroundColor(.sgfTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SGFSpacing.xl)

            Button("Log First Period") {
                onAddFirst()
            }
            .buttonStyle(SGFPrimaryButtonStyle())
            .padding(.horizontal, SGFSpacing.lg)
        }
    }
}

// MARK: - Add Period Sheet

struct AddPeriodSheet: View {
    @ObservedObject var viewModel: CycleHistoryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Start Date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log Period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.logPeriod(date: selectedDate, notes: notes)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    CycleHistoryView()
}
