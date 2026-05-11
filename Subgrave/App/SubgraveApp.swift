//
//  SubgraveApp.swift
//  Subgrave
//
//  Uygulama giriş noktası. ModelContainer'ı tüm Scene'e enjekte eder.
//

import SwiftUI
import SwiftData

@main
struct SubgraveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(PersistenceController.shared)
    }
}
