//
//  AddSubscriptionViewModel.swift
//  Subgrave
//
//  Yeni abonelik ekleme veya mevcut aboneliği düzenleme formunun iş mantığı.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class AddSubscriptionViewModel {
    // MARK: - Form State
    var name: String = ""
    var category: SubscriptionCategory = .video
    var billingCycle: BillingCycle = .monthly
    var priceText: String = ""
    var startDate: Date = .init()
    var notes: String = ""

    // MARK: - State
    var isSaving: Bool = false
    var errorMessage: String?

    private let repository: SubscriptionRepositoryProtocol
    private let editingSubscription: Subscription?

    /// Düzenleme modu mu?
    var isEditing: Bool { editingSubscription != nil }

    /// Form başlığı.
    var formTitle: String {
        isEditing ? "Aboneliği Düzenle" : "Yeni Abonelik"
    }

    // MARK: - Init
    init(repository: SubscriptionRepositoryProtocol, editing subscription: Subscription? = nil) {
        self.repository = repository
        self.editingSubscription = subscription
        if let s = subscription {
            self.name = s.name
            self.category = s.category
            self.billingCycle = s.billingCycle
            self.priceText = String(format: "%.2f", s.price)
            self.startDate = s.startDate
            self.notes = s.notes
        }
    }

    // MARK: - Validation
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        parsedPrice != nil &&
        (parsedPrice ?? 0) >= 0
    }

    /// Türkçe ondalık ayraç (virgül) ve nokta'yı destekler.
    var parsedPrice: Double? {
        let normalized = priceText.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    // MARK: - Templates
    /// Hızlı seçim için popüler abonelik şablonları.
    static let templates: [SubscriptionTemplate] = [
        .init(name: "Spotify",         category: .music,    price: 59.99,  cycle: .monthly),
        .init(name: "Netflix",         category: .video,    price: 149.99, cycle: .monthly),
        .init(name: "YouTube Premium", category: .video,    price: 57.99,  cycle: .monthly),
        .init(name: "BluTV",           category: .video,    price: 89.90,  cycle: .monthly),
        .init(name: "Disney+",         category: .video,    price: 64.99,  cycle: .monthly),
        .init(name: "Apple Music",     category: .music,    price: 29.99,  cycle: .monthly),
        .init(name: "iCloud+ 200GB",   category: .cloud,    price: 29.99,  cycle: .monthly),
        .init(name: "Adobe CC",        category: .software, price: 7499,   cycle: .yearly),
        .init(name: "Xbox Game Pass",  category: .gaming,   price: 99.99,  cycle: .monthly),
        .init(name: "Exxen",           category: .video,    price: 79.90,  cycle: .monthly)
    ]

    func applyTemplate(_ template: SubscriptionTemplate) {
        name = template.name
        category = template.category
        priceText = String(format: "%.2f", template.price)
        billingCycle = template.cycle
    }

    // MARK: - Save
    func save() -> Bool {
        guard isFormValid, let price = parsedPrice else {
            errorMessage = "Form eksik. Adı ve geçerli bir ücreti gir."
            return false
        }
        isSaving = true
        defer { isSaving = false }
        do {
            if let existing = editingSubscription {
                existing.name = name.trimmingCharacters(in: .whitespaces)
                existing.category = category
                existing.billingCycle = billingCycle
                existing.price = price
                existing.startDate = startDate
                existing.notes = notes
                try repository.update(existing)
            } else {
                let newSub = Subscription(
                    name: name.trimmingCharacters(in: .whitespaces),
                    category: category,
                    billingCycle: billingCycle,
                    price: price,
                    startDate: startDate,
                    notes: notes
                )
                try repository.save(newSub)
                NotificationService.shared.scheduleRenewalReminder(for: newSub)
            }
            return true
        } catch {
            errorMessage = "Kayıt başarısız: \(error.localizedDescription)"
            return false
        }
    }
}

// MARK: - Template
struct SubscriptionTemplate: Identifiable, Hashable {
    let name: String
    let category: SubscriptionCategory
    let price: Double
    let cycle: BillingCycle
    var id: String { name }
}
