//
//  PersistenceController.swift
//  Subgrave
//
//  ModelContainer'ı tek noktadan yönet, ilk açılışta seed verisi ekle.
//

import Foundation
import SwiftData

@MainActor
enum PersistenceController {
    /// Uygulamanın kullanacağı ana ModelContainer.
    static let shared: ModelContainer = {
        let schema = Schema([Subscription.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            seedIfNeeded(in: container.mainContext)
            return container
        } catch {
            fatalError("ModelContainer kurulamadı: \(error)")
        }
    }()

    /// Önizlemeler için bellekte yaşayan container.
    static let preview: ModelContainer = {
        let schema = Schema([Subscription.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            MockData.seedSampleData(in: container.mainContext)
            return container
        } catch {
            fatalError("Preview container kurulamadı: \(error)")
        }
    }()

    /// Gerçek depoda hiç abonelik yoksa örnek veriyi yerleştirir.
    static func seedIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<Subscription>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        MockData.seedSampleData(in: context)
    }
}
