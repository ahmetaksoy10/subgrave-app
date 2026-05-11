//
//  DashboardView.swift
//  Subgrave
//
//  Ana sayfa – metrik kartları, yenilemeler, son aktivite ve grafik.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    @State private var showAddSheet = false
    @Environment(\.modelContext) private var modelContext

    init(repository: SubscriptionRepositoryProtocol) {
        _viewModel = State(initialValue: DashboardViewModel(repository: repository))
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    LazyVGrid(columns: columns, spacing: 12) {
                        MetricCardView(
                            title: "Aktif abonelik",
                            value: "\(viewModel.activeCount)",
                            icon: "leaf.fill",
                            tint: Color.subgraveLiving.opacity(0.9)
                        )
                        MetricCardView(
                            title: "Aylık toplam",
                            value: viewModel.monthlyTotal.subgraveCurrency,
                            icon: "creditcard.fill",
                            tint: .subgraveAccent
                        )
                        MetricCardView(
                            title: "Mezarlıkta toplam",
                            value: viewModel.graveyardTotal.subgraveCurrencyShort,
                            icon: "moon.stars.fill",
                            tint: .subgraveSecondary
                        )
                        MetricCardView(
                            title: viewModel.ghostCount > 0
                                ? "Hayalet alarm!"
                                : "Hayalet yok",
                            value: "\(viewModel.ghostCount)",
                            icon: viewModel.ghostCount > 0
                                ? "exclamationmark.triangle.fill"
                                : "checkmark.seal.fill",
                            tint: viewModel.ghostCount > 0 ? .subgraveAlert : Color.subgraveLiving,
                            emphasized: viewModel.ghostCount > 0
                        )
                    }

                    UpcomingRenewalsView(renewals: viewModel.upcomingRenewals)

                    RecentActivityView(items: viewModel.recentActivity)

                    YearlySpendingChartView(data: viewModel.yearlySpending)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color.subgraveBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.subgraveAccent)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet, onDismiss: { viewModel.load() }) {
                AddSubscriptionView(
                    repository: SwiftDataSubscriptionRepository(modelContext: modelContext)
                )
            }
            .refreshable { viewModel.load() }
            .onAppear { viewModel.load() }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Subgrave")
                .font(.system(size: 34, weight: .semibold, design: .serif))
                .foregroundStyle(Color.subgraveText)
            Text("Aboneliklerinin sakin bahçesi.")
                .font(.subheadline)
                .foregroundStyle(Color.subgraveTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

#Preview {
    DashboardView(
        repository: SwiftDataSubscriptionRepository(
            modelContext: PersistenceController.preview.mainContext
        )
    )
    .modelContainer(PersistenceController.preview)
}
