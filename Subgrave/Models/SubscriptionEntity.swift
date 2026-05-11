//
//  SubscriptionEntity.swift
//  Subgrave
//
//  App Intents tarafından tanınan abonelik temsili.
//  Shortcuts ve Siri, kullanıcının aboneliklerini bu entity üzerinden seçer.
//

import Foundation
import AppIntents
import SwiftData

/// AppIntent ekosisteminde bir aboneliği temsil eder.
/// Gerçek `Subscription` (SwiftData @Model) referansını id ile bulup eşler.
struct SubscriptionEntity: AppEntity, Identifiable {
    /// Subscription'ın UUID'si.
    var id: UUID
    /// Görünür ad (Spotify, Netflix vb.).
    var name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Abonelik")
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static var defaultQuery = SubscriptionEntityQuery()
}
