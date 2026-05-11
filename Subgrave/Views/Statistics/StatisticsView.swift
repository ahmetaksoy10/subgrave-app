//
//  StatisticsView.swift
//  Subgrave
//
//  Spotify Wrapped tarzı yıllık özet ekranı.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @State private var viewModel: StatisticsViewModel

    init(repository: SubscriptionRepositoryProtocol) {
        _viewModel = State(initialValue: StatisticsViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    wrappedHeader

                    // Hero kart – bu yıl
                    heroCard

                    // En uzun yaşayan
                    if let oldest = viewModel.longestLiving {
                        recordCard(
                            title: "Aramızdan en uzun yaşayan",
                            tagline: "\(oldest.lifespanInDays) gündür sebatkar",
                            subtitle: oldest.name,
                            icon: "infinity",
                            tint: Color.subgraveLiving
                        )
                    }

                    // En pahalı (gün başı)
                    if let pricey = viewModel.mostExpensivePerDay {
                        recordCard(
                            title: "Cüzdana en pahalıya gelen",
                            tagline: "Günde \(viewModel.costPerDay(for: pricey).subgraveCurrency)",
                            subtitle: pricey.name,
                            icon: "creditcard.fill",
                            tint: Color.subgraveAlert
                        )
                    }

                    // Toplam tüketim
                    totalConsumptionCard

                    // Kategori dağılımı
                    if !viewModel.spendingByCategory.isEmpty {
                        categoryBreakdownCard
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color.subgraveBackground)
            .navigationTitle("Yıllık Rapor")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.load() }
        }
    }

    // MARK: - Header
    private var wrappedHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date().subgraveYear)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.subgraveAccent)
            SubgraveSerifText("Senin Subgrave Yılın", size: 32)
            Text("Dijital tüketiminin sade hikayesi")
                .font(.subheadline)
                .foregroundStyle(Color.subgraveTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    // MARK: - Hero
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Bu yıl")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text("\(viewModel.subscriptionsThisYear) abonelikle yaşadın.")
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
            if viewModel.neverUsedCount > 0 {
                Text("Bunların \(viewModel.neverUsedCount) tanesini hiç açmadın.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            HStack {
                Image(systemName: "leaf.circle")
                    .foregroundStyle(.white)
                Text("Mezarlığa \(viewModel.buriedThisYear.count) abonelik gönderdin.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.subgraveAccent, Color.subgraveSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.subgraveAccent.opacity(0.25), radius: 12, x: 0, y: 8)
    }

    // MARK: - Record
    private func recordCard(
        title: String,
        tagline: String,
        subtitle: String,
        icon: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.subgraveTextSecondary)
            }
            Text(subtitle)
                .font(.system(.title3, design: .serif).weight(.semibold))
                .foregroundStyle(Color.subgraveText)
            Text(tagline)
                .font(.subheadline)
                .foregroundStyle(Color.subgraveTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .subgraveCard()
    }

    // MARK: - Total
    private var totalConsumptionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "infinity.circle.fill")
                    .foregroundStyle(Color.subgraveAccent)
                Text("Toplam dijital tüketim")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.subgraveTextSecondary)
            }
            Text(viewModel.totalDigitalConsumption.subgraveCurrency)
                .font(.system(.largeTitle, design: .serif).weight(.semibold))
                .foregroundStyle(Color.subgraveText)
            Text("Tüm zamanların boyunca abonelikler için verdiğin tahmini tutar.")
                .font(.subheadline)
                .foregroundStyle(Color.subgraveTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .subgraveCard()
    }

    // MARK: - Category
    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(Color.subgraveAccent)
                Text("Kategori dağılımı")
                    .font(.headline)
                    .foregroundStyle(Color.subgraveText)
            }
            Chart(viewModel.spendingByCategory) { item in
                SectorMark(
                    angle: .value("Tutar", item.amount),
                    innerRadius: .ratio(0.55),
                    angularInset: 2
                )
                .foregroundStyle(item.category.tint)
                .annotation(position: .overlay) {
                    if item.amount / viewModel.totalDigitalConsumption > 0.08 {
                        Text(item.category.displayName)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.subgraveText)
                    }
                }
            }
            .frame(height: 220)

            // Legend
            VStack(alignment: .leading, spacing: 6) {
                ForEach(viewModel.spendingByCategory) { item in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.category.tint)
                            .frame(width: 12, height: 12)
                        Text(item.category.displayName)
                            .font(.caption)
                            .foregroundStyle(Color.subgraveText)
                        Spacer()
                        Text(item.amount.subgraveCurrencyShort)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.subgraveTextSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .subgraveCard()
    }
}
