//
//  DashboardViewModel.swift
//  Subgrave
//
//  Ana sayfanın iş mantığı: metrik kartları, yenilemeler, harcama grafiği.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class DashboardViewModel {
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
            errorMessage = "Dashboard yüklenemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Metrik Kartları
    var activeCount: Int {
        allSubscriptions.filter { $0.isActive }.count
    }

    var monthlyTotal: Double {
        allSubscriptions.filter { $0.isActive }.reduce(0) { $0 + $1.monthlyEquivalent }
    }

    var graveyardTotal: Double {
        allSubscriptions.filter { !$0.isActive }.reduce(0) { $0 + $1.totalPaid }
    }

    var ghostCount: Int {
        allSubscriptions.filter { $0.isGhost }.count
    }

    // MARK: - Bu Ay Yenilenecekler
    /// Sonraki 30 gün içinde yenilenecek aktif abonelikler.
    var upcomingRenewals: [Subscription] {
        let now = Date()
        let horizon = Calendar.current.date(byAdding: .day, value: 30, to: now) ?? now
        return allSubscriptions
            .filter { $0.isActive }
            .compactMap { sub in
                guard let next = sub.nextRenewalDate, next <= horizon else { return nil }
                return sub
            }
            .sorted { ($0.nextRenewalDate ?? Date()) < ($1.nextRenewalDate ?? Date()) }
    }

    // MARK: - Son Aktivite
    /// Son aktivite akışı: yeni eklenenler ve mezarlığa gönderilenler.
    var recentActivity: [ActivityItem] {
        let added = allSubscriptions.map {
            ActivityItem(id: "add-\($0.id)", date: $0.createdAt, kind: .added, subscription: $0)
        }
        let buried = allSubscriptions
            .filter { !$0.isActive }
            .compactMap { sub -> ActivityItem? in
                guard let end = sub.endDate else { return nil }
                return ActivityItem(id: "bury-\(sub.id)", date: end, kind: .buried, subscription: sub)
            }
        return (added + buried)
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Yıllık Harcama
    /// Son 12 ay için ay-bazlı harcama (sadece aktifler – tahmini).
    /// Mezar olanlar için iptal tarihinden önceki dönemleri de dahil eder.
    var yearlySpending: [MonthlySpending] {
        var result: [MonthlySpending] = []
        let now = Date()
        let calendar = Calendar.current
        for offset in (0..<12).reversed() {
            guard let monthStart = calendar.date(byAdding: .month, value: -offset, to: now),
                  let interval = calendar.dateInterval(of: .month, for: monthStart) else { continue }
            // O ay aboneliği aktif olanların aylık eşdeğeri toplamı.
            let amount = allSubscriptions
                .filter { sub in
                    sub.startDate <= interval.end &&
                    (sub.endDate == nil || sub.endDate! >= interval.start)
                }
                .reduce(0) { $0 + $1.monthlyEquivalent }
            result.append(MonthlySpending(
                date: interval.start,
                amount: amount
            ))
        }
        return result
    }
}

// MARK: - Yardımcı Tipler
struct ActivityItem: Identifiable, Hashable {
    enum Kind: String {
        case added, buried
    }
    let id: String
    let date: Date
    let kind: Kind
    let subscription: Subscription

    static func == (lhs: ActivityItem, rhs: ActivityItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct MonthlySpending: Identifiable, Hashable {
    let date: Date
    let amount: Double
    var id: Date { date }

    var monthLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}
