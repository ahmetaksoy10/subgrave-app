//
//  MarkSubscriptionUsedIntent.swift
//  Subgrave
//
//  Subgrave'in Shortcuts'ta sunduğu ana eylem.
//  Kullanıcı bunu otomasyon olarak ekler:
//    "Spotify uygulaması açıldığında → Subgrave: Aboneliği Kullanıldı İşaretle"
//

import Foundation
import AppIntents
import SwiftData

struct MarkSubscriptionUsedIntent: AppIntent {
    static var title: LocalizedStringResource = "Aboneliği Kullanıldı İşaretle"
    static var description: IntentDescription = "Subgrave'e bu aboneliği bugün kullandığınızı söyler. Genellikle Shortcuts otomasyonu ile uygulama açılışına bağlanır."

    /// Shortcuts'ta görünen parametre. Kullanıcı abonelik listesinden seçer.
    @Parameter(title: "Abonelik")
    var subscription: SubscriptionEntity

    /// Eylem arka planda da çalışabilir (uygulama açılmasına gerek yok).
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let name = subscription.name
        try await updateLastUsedDate(for: subscription.id)
        return .result(
            dialog: IntentDialog("\(name) için kullanım zamanı güncellendi. Yaşıyor ve nefes alıyor.")
        )
    }

    /// SwiftData yazımı – MainActor üzerinde yapılır.
    @MainActor
    private func updateLastUsedDate(for id: UUID) async throws {
        let context = PersistenceController.shared.mainContext
        let descriptor = FetchDescriptor<Subscription>(
            predicate: #Predicate { $0.id == id }
        )
        guard let target = try context.fetch(descriptor).first else {
            throw IntentError.subscriptionNotFound
        }
        target.lastUsedDate = Date()
        try context.save()
    }
}

/// Eylem tarafından fırlatılabilecek hatalar.
enum IntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case subscriptionNotFound

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .subscriptionNotFound:
            return "Bu abonelik artık Subgrave'de bulunamadı."
        }
    }
}
