//
//  ContentView.swift
//  Subgrave
//
//  Ana TabView – Yaşayanlar, Mezarlık, İstatistikler ve Ana Sayfa.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    /// Başlangıç tab'ı: env variable ile override edilebilir (UI test ve görsel test için).
    @State private var selectedTab: Int = {
        if let raw = ProcessInfo.processInfo.environment["SUBGRAVE_INITIAL_TAB"],
           let value = Int(raw) {
            return value
        }
        return 0
    }()

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(repository: makeRepository())
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
                .tag(0)

            LivingSubscriptionsView(repository: makeRepository())
                .tabItem {
                    Label("Yaşayanlar", systemImage: "leaf.fill")
                }
                .tag(1)

            GraveyardView(repository: makeRepository())
                .tabItem {
                    Label("Mezarlık", systemImage: "moon.stars.fill")
                }
                .tag(2)

            StatisticsView(repository: makeRepository())
                .tabItem {
                    Label("İstatistik", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
        .tint(.subgraveAccent)
        // Bildirim izni: ilk abonelik eklendiğinde istenir (NotificationService içinde).
    }

    private func makeRepository() -> SubscriptionRepositoryProtocol {
        SwiftDataSubscriptionRepository(modelContext: modelContext)
    }
}

#Preview {
    ContentView()
        .modelContainer(PersistenceController.preview)
}
