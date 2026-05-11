//
//  SubgraveShortcuts.swift
//  Subgrave
//
//  Sistem geneline yayınlanan kısayollar.
//  Kullanıcı Shortcuts uygulamasını açmasa bile Spotlight ve Siri bunları görür.
//

import Foundation
import AppIntents

struct SubgraveShortcuts: AppShortcutsProvider {
    /// Renk teması Shortcuts kart arkaplanı için.
    static var shortcutTileColor: ShortcutTileColor = .purple

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: MarkSubscriptionUsedIntent(),
            phrases: [
                "\(.applicationName) abonelik kullandım",
                "\(.applicationName) ile \(\.$subscription) kullanıldı işaretle",
                "\(.applicationName) için kullanım kaydet"
            ],
            shortTitle: "Kullanıldı İşaretle",
            systemImageName: "checkmark.circle.fill"
        )
    }
}
