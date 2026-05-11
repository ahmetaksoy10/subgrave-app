//
//  StatisticsViewModel.swift
//  Subgrave
//
//  Spotify Wrapped tarzı yıllık rapor için iş mantığı.
//

import Foundation

@MainActor
@Observable
final class StatisticsViewModel {
    // MARK: - State
    var allSubscriptions: [Subscription] = []
    var errorMessage: String?

    // MARK: - Dependencies
    private let repository: SubscriptionRepositoryProtocol

    init(repository: SubscriptionRepositoryProtocol) {
        self.repository = repository
        load()
    }

    func load() {
        do {
            allSubscriptions = try repository.fetchAll()
        } catch {
            errorMessage = "İstatistikler yüklenemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Wrapped İstatistikleri
    /// Bu yıl içinde aktif olmuş toplam abonelik sayısı.
    var subscriptionsThisYear: Int {
        let year = Date().yearValue
        return allSubscriptions.filter { sub in
            let startYear = sub.startDate.yearValue
            let endYear = sub.endDate?.yearValue ?? year
            return startYear <= year && endYear >= year
        }.count
    }

    /// Hiç kullanılmamış abonelik sayısı.
    var neverUsedCount: Int {
        allSubscriptions.filter { $0.lastUsedDate == nil }.count
    }

    /// En uzun yaşayan abonelik.
    var longestLiving: Subscription? {
        allSubscriptions.max(by: { $0.lifespanInDays < $1.lifespanInDays })
    }

    /// En pahalı – saat bazlı maliyet (en az kullanılan ama en çok ödenen).
    /// Tahmini saat = lastUsedDate'den geriye günlük 1 saat varsayımı yerine,
    /// basit bir oran: totalPaid / lifespanInDays (gün başı maliyet).
    var mostExpensivePerDay: Subscription? {
        allSubscriptions
            .filter { $0.lifespanInDays > 0 }
            .max(by: { ($0.totalPaid / Double($0.lifespanInDays)) < ($1.totalPaid / Double($1.lifespanInDays)) })
    }

    /// Tüm zamanların toplam dijital tüketimi (TL).
    var totalDigitalConsumption: Double {
        allSubscriptions.reduce(0) { $0 + $1.totalPaid }
    }

    /// Kategoriye göre dağılım (pasta grafiği için).
    var spendingByCategory: [CategorySpending] {
        let grouped = Dictionary(grouping: allSubscriptions) { $0.category }
        return grouped.map { CategorySpending(
            category: $0.key,
            amount: $0.value.reduce(0) { $0 + $1.totalPaid }
        )}
        .filter { $0.amount > 0 }
        .sorted { $0.amount > $1.amount }
    }

    /// Bu yıl mezara gönderilenler.
    var buriedThisYear: [Subscription] {
        let year = Date().yearValue
        return allSubscriptions.filter {
            !$0.isActive && ($0.endDate?.yearValue ?? 0) == year
        }
    }

    /// Pahalı oluşan mezar abonelikleri için "günde kaç saat kullanılması gerekirdi" gibi
    /// ironik bir hesaplama yapmak yerine, gün başına maliyet basit bir metrik.
    func costPerDay(for subscription: Subscription) -> Double {
        let days = max(1, subscription.lifespanInDays)
        return subscription.totalPaid / Double(days)
    }
}

// MARK: - Yardımcı Tipler
struct CategorySpending: Identifiable, Hashable {
    let category: SubscriptionCategory
    let amount: Double
    var id: String { category.rawValue }
}
