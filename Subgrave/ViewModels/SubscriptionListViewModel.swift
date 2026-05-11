//
//  SubscriptionListViewModel.swift
//  Subgrave
//
//  Yaşayanlar (aktif abonelikler) ekranının iş mantığı.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class SubscriptionListViewModel {
    // MARK: - State
    var subscriptions: [Subscription] = []
    var selectedCategory: SubscriptionCategory?
    var sortOption: SortOption = .priceDescending
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies
    private let repository: SubscriptionRepositoryProtocol

    init(repository: SubscriptionRepositoryProtocol) {
        self.repository = repository
        load()
    }

    // MARK: - Actions
    func load() {
        isLoading = true
        defer { isLoading = false }
        do {
            subscriptions = try repository.fetchActive()
        } catch {
            errorMessage = "Abonelikler yüklenemedi: \(error.localizedDescription)"
        }
    }

    func sendToGraveyard(_ subscription: Subscription, reason: CancelReason, finalNote: String?) {
        do {
            try repository.sendToGraveyard(subscription, reason: reason, finalNote: finalNote)
            NotificationService.shared.cancelReminder(for: subscription)
            load()
        } catch {
            errorMessage = "Mezarlığa gönderilirken hata: \(error.localizedDescription)"
        }
    }

    func delete(_ subscription: Subscription) {
        do {
            try repository.delete(subscription)
            NotificationService.shared.cancelReminder(for: subscription)
            load()
        } catch {
            errorMessage = "Silinirken hata: \(error.localizedDescription)"
        }
    }

    func markAsUsedNow(_ subscription: Subscription) {
        subscription.lastUsedDate = Date()
        try? repository.update(subscription)
        load()
    }

    // MARK: - Derived
    /// Filtre + arama + sıralama uygulanmış liste.
    var filtered: [Subscription] {
        var list = subscriptions
        if let cat = selectedCategory {
            list = list.filter { $0.category == cat }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.lowercased()
            list = list.filter { $0.name.lowercased().contains(q) }
        }
        switch sortOption {
        case .priceDescending: list.sort { $0.monthlyEquivalent > $1.monthlyEquivalent }
        case .priceAscending:  list.sort { $0.monthlyEquivalent < $1.monthlyEquivalent }
        case .ageDescending:   list.sort { $0.startDate < $1.startDate }
        case .ageAscending:    list.sort { $0.startDate > $1.startDate }
        case .usageFrequency:
            // Hayaletler önce, sonra son kullanımı eski olanlar.
            list.sort { lhs, rhs in
                let l = lhs.lastUsedDate ?? Date.distantPast
                let r = rhs.lastUsedDate ?? Date.distantPast
                return l < r
            }
        }
        return list
    }

    var totalMonthlyExpense: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyEquivalent }
    }

    var ghostCount: Int {
        subscriptions.filter { $0.isGhost }.count
    }
}
