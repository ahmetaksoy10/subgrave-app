//
//  SubscriptionEntityQuery.swift
//  Subgrave
//
//  Shortcuts uygulamasındaki "Aboneliği Seç" parametre seçicisini besleyen sorgu.
//

import Foundation
import AppIntents
import SwiftData

struct SubscriptionEntityQuery: EntityQuery {
    /// Shortcuts içinde id ile entity isteme.
    func entities(for identifiers: [SubscriptionEntity.ID]) async throws -> [SubscriptionEntity] {
        let all = try await fetchAllEntities()
        return all.filter { identifiers.contains($0.id) }
    }

    /// Shortcuts arayüzünde liste açıldığında gösterilen öneriler — aktif abonelikler.
    func suggestedEntities() async throws -> [SubscriptionEntity] {
        try await fetchAllEntities(activeOnly: true)
    }

    /// Tüm sonuçları döndürür (default davranış).
    func defaultResult() async -> SubscriptionEntity? {
        try? await fetchAllEntities(activeOnly: true).first
    }

    /// ModelContainer.shared üzerinden SwiftData okuma.
    /// @MainActor olduğu için ana aktöre atlıyoruz.
    @MainActor
    private func fetchAllEntities(activeOnly: Bool = false) async throws -> [SubscriptionEntity] {
        let context = PersistenceController.shared.mainContext
        let descriptor = FetchDescriptor<Subscription>(
            sortBy: [SortDescriptor(\.name)]
        )
        let subscriptions = try context.fetch(descriptor)
        let filtered = activeOnly ? subscriptions.filter { $0.isActive } : subscriptions
        return filtered.map { SubscriptionEntity(id: $0.id, name: $0.name) }
    }
}
