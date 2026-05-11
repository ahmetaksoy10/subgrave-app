//
//  SubscriptionRepository.swift
//  Subgrave
//
//  Repository pattern – ViewModel'lar veri erişimini bu protocol üzerinden yapar.
//  Test edilebilirlik için protocol-oriented; gerçek implementasyon SwiftData üzerinde.
//

import Foundation
import SwiftData

/// Abonelik veri katmanı için soyutlama.
@MainActor
protocol SubscriptionRepositoryProtocol {
    func fetchAll() throws -> [Subscription]
    func fetchActive() throws -> [Subscription]
    func fetchGraveyard() throws -> [Subscription]
    func save(_ subscription: Subscription) throws
    func update(_ subscription: Subscription) throws
    func delete(_ subscription: Subscription) throws
    func sendToGraveyard(_ subscription: Subscription, reason: CancelReason, finalNote: String?) throws
    func resurrect(_ subscription: Subscription) throws
}

/// SwiftData destekli somut implementasyon.
@MainActor
final class SwiftDataSubscriptionRepository: SubscriptionRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchActive() throws -> [Subscription] {
        // SwiftData predicate'inde nil karşılaştırması için iki fazlı yaklaşım.
        let all = try fetchAll()
        return all.filter { $0.isActive }
    }

    func fetchGraveyard() throws -> [Subscription] {
        let all = try fetchAll()
        return all.filter { !$0.isActive }
    }

    func save(_ subscription: Subscription) throws {
        modelContext.insert(subscription)
        try modelContext.save()
    }

    func update(_ subscription: Subscription) throws {
        // @Model nesneler doğrudan değiştirilebilir; sadece kaydı zorla.
        try modelContext.save()
    }

    func delete(_ subscription: Subscription) throws {
        modelContext.delete(subscription)
        try modelContext.save()
    }

    func sendToGraveyard(_ subscription: Subscription, reason: CancelReason, finalNote: String?) throws {
        subscription.endDate = Date()
        subscription.cancelReason = reason
        if let note = finalNote, !note.isEmpty {
            // Mevcut nota ekleme: kullanıcı önceki notlarını kaybetmesin.
            if subscription.notes.isEmpty {
                subscription.notes = note
            } else {
                subscription.notes += "\n— Veda notu —\n\(note)"
            }
        }
        try modelContext.save()
    }

    func resurrect(_ subscription: Subscription) throws {
        // Mezardan dönen abonelik için yeni bir yaşam başlatıyoruz.
        subscription.endDate = nil
        subscription.cancelReason = nil
        subscription.startDate = Date()
        subscription.lastUsedDate = nil
        subscription.isResurrected = true
        try modelContext.save()
    }
}
