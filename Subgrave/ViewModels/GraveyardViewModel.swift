//
//  GraveyardViewModel.swift
//  Subgrave
//
//  Mezarlık ekranının iş mantığı.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class GraveyardViewModel {
    // MARK: - State
    var graves: [Subscription] = []
    var searchText: String = ""
    var groupByYear: Bool = true
    var showOnlyResurrected: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies
    private let repository: SubscriptionRepositoryProtocol

    init(repository: SubscriptionRepositoryProtocol) {
        self.repository = repository
        load()
    }

    // MARK: - Actions
    func load() {
        do {
            graves = try repository.fetchGraveyard()
        } catch {
            errorMessage = "Mezarlık yüklenemedi: \(error.localizedDescription)"
        }
    }

    func resurrect(_ subscription: Subscription) {
        do {
            try repository.resurrect(subscription)
            load()
        } catch {
            errorMessage = "Diriliş başarısız: \(error.localizedDescription)"
        }
    }

    func delete(_ subscription: Subscription) {
        do {
            try repository.delete(subscription)
            load()
        } catch {
            errorMessage = "Silinirken hata: \(error.localizedDescription)"
        }
    }

    // MARK: - Derived
    var filtered: [Subscription] {
        var list = graves
        if showOnlyResurrected {
            list = list.filter { $0.isResurrected }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.lowercased()
            list = list.filter { $0.name.lowercased().contains(q) }
        }
        // En yeni mezarlar önce.
        return list.sorted { ($0.endDate ?? Date()) > ($1.endDate ?? Date()) }
    }

    /// Yıla göre gruplar – TombstoneView'da Section başlığı için.
    var groupedByYear: [(year: Int, items: [Subscription])] {
        let grouped = Dictionary(grouping: filtered) { $0.endDate?.yearValue ?? 0 }
        return grouped
            .map { (year: $0.key, items: $0.value) }
            .sorted { $0.year > $1.year }
    }

    var totalSpent: Double {
        graves.reduce(0) { $0 + $1.totalPaid }
    }
}
