//
//  GraveyardView.swift
//  Subgrave
//
//  Mezarlık ekranı – yıla göre gruplanmış taş kartlar.
//

import SwiftUI

struct GraveyardView: View {
    @State private var viewModel: GraveyardViewModel

    init(repository: SubscriptionRepositoryProtocol) {
        _viewModel = State(initialValue: GraveyardViewModel(repository: repository))
    }

    private let columns = [GridItem(.adaptive(minimum: 220), spacing: 24)]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.subgraveBackground.ignoresSafeArea()

                if viewModel.filtered.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Açıklama metni
                            graveyardHeader

                            if viewModel.groupByYear {
                                ForEach(viewModel.groupedByYear, id: \.year) { group in
                                    yearSection(year: group.year, items: group.items)
                                }
                            } else {
                                LazyVGrid(columns: columns, alignment: .center, spacing: 32) {
                                    ForEach(viewModel.filtered) { sub in
                                        TombstoneView(
                                            subscription: sub,
                                            onResurrect: { viewModel.resurrect(sub) },
                                            onDelete: { viewModel.delete(sub) }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Mezarlık")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Mezar taşı ara")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("Yıla göre gruplandır", isOn: $viewModel.groupByYear)
                        Toggle("Sadece dirilenler", isOn: $viewModel.showOnlyResurrected)
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(Color.subgraveAccent)
                    }
                }
            }
            .onAppear { viewModel.load() }
        }
    }

    // MARK: - Header
    private var graveyardHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(Color.subgraveSecondary)
                Text("Huzurla anılsınlar")
                    .font(.system(.headline, design: .serif).weight(.semibold))
                    .foregroundStyle(Color.subgraveText)
            }
            Text("Bu bahçe, vedalaştığın aboneliklerin sakin köşesi. Toplam \(viewModel.totalSpent.subgraveCurrencyShort) burada uyumakta.")
                .font(.subheadline)
                .foregroundStyle(Color.subgraveTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    // MARK: - Year Section
    private func yearSection(year: Int, items: [Subscription]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(String(year))")
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(Color.subgraveText)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.subgraveGrave.opacity(0.5))
            }
            LazyVGrid(columns: columns, alignment: .center, spacing: 32) {
                ForEach(items) { sub in
                    TombstoneView(
                        subscription: sub,
                        onResurrect: { viewModel.resurrect(sub) },
                        onDelete: { viewModel.delete(sub) }
                    )
                }
            }
        }
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars")
                .font(.system(size: 56))
                .foregroundStyle(Color.subgraveStoneDark)
            Text("Mezarlık sessiz")
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(Color.subgraveText)
            Text("Henüz vedalaştığın bir abonelik yok. Bu güzel bir şey.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.subgraveTextSecondary)
                .padding(.horizontal, 32)
        }
    }
}
