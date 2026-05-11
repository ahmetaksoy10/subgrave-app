//
//  MockData.swift
//  Subgrave
//
//  İlk açılış ve preview için örnek abonelikler.
//  Türk kullanıcılarına uygun, fiyatlar TL.
//

import Foundation
import SwiftData

@MainActor
enum MockData {
    /// Verilen ModelContext'e örnek aktif ve mezar aboneliklerini ekler.
    static func seedSampleData(in context: ModelContext) {
        let calendar = Calendar.current
        let now = Date()

        // Yardımcı: X ay - Y gün önce başlamış gibi göster.
        // Böylece yenileme tarihleri 30 günlük pencere içinde dağılır.
        func dateAgo(months: Int, daysExtra: Int = 0) -> Date {
            let monthShifted = calendar.date(byAdding: .month, value: -months, to: now) ?? now
            return calendar.date(byAdding: .day, value: -daysExtra, to: monthShifted) ?? monthShifted
        }

        // MARK: - Yaşayanlar (Aktif)
        let active: [Subscription] = [
            Subscription(
                name: "Spotify",
                category: .music,
                billingCycle: .monthly,
                price: 59.99,
                startDate: dateAgo(months: 28, daysExtra: 4),     // ~4 gün sonra yenilenir
                lastUsedDate: calendar.date(byAdding: .day, value: -1, to: now),
                notes: "Çalma listelerim canımın yongası.",
                createdAt: dateAgo(months: 28, daysExtra: 4)
            ),
            Subscription(
                name: "Netflix",
                category: .video,
                billingCycle: .monthly,
                price: 149.99,
                startDate: dateAgo(months: 14, daysExtra: 12),    // ~12 gün sonra
                lastUsedDate: calendar.date(byAdding: .day, value: -3, to: now),
                notes: "Standart paket.",
                createdAt: dateAgo(months: 14, daysExtra: 12)
            ),
            Subscription(
                name: "YouTube Premium",
                category: .video,
                billingCycle: .monthly,
                price: 57.99,
                startDate: dateAgo(months: 8, daysExtra: 22),     // ~22 gün sonra
                lastUsedDate: calendar.date(byAdding: .hour, value: -6, to: now),
                notes: "Reklamsız izlemek paha biçilemez.",
                createdAt: dateAgo(months: 8, daysExtra: 22)
            ),
            Subscription(
                name: "BluTV",
                category: .video,
                billingCycle: .monthly,
                price: 89.90,
                startDate: dateAgo(months: 6, daysExtra: 17),     // ~17 gün sonra
                lastUsedDate: calendar.date(byAdding: .day, value: -45, to: now), // hayalet
                notes: "Yerli yapımlar için açtım, sonra unuttum.",
                createdAt: dateAgo(months: 6, daysExtra: 17)
            ),
            Subscription(
                name: "iCloud+ 200GB",
                category: .cloud,
                billingCycle: .monthly,
                price: 29.99,
                startDate: dateAgo(months: 22, daysExtra: 8),     // ~8 gün sonra
                lastUsedDate: now,
                notes: "Yedeklemenin huzuru.",
                createdAt: dateAgo(months: 22, daysExtra: 8)
            )
        ]

        // MARK: - Mezarlık (İptal Edilmiş)
        let graveyard: [Subscription] = [
            Subscription(
                name: "Exxen",
                category: .video,
                billingCycle: .monthly,
                price: 79.90,
                startDate: dateFrom(year: 2023, month: 6, day: 1),
                endDate: dateFrom(year: 2024, month: 1, day: 15),
                cancelReason: .notUsing,
                lastUsedDate: dateFrom(year: 2023, month: 11, day: 20),
                notes: "İlk heyecan geçince hiç açmadım.",
                createdAt: dateFrom(year: 2023, month: 6, day: 1)
            ),
            Subscription(
                name: "Disney+",
                category: .video,
                billingCycle: .monthly,
                price: 64.99,
                startDate: dateFrom(year: 2022, month: 11, day: 5),
                endDate: dateFrom(year: 2024, month: 3, day: 10),
                cancelReason: .priceIncrease,
                lastUsedDate: dateFrom(year: 2024, month: 2, day: 28),
                notes: "Mandalorian bitince anlam kalmadı.",
                createdAt: dateFrom(year: 2022, month: 11, day: 5)
            ),
            Subscription(
                name: "Adobe Creative Cloud",
                category: .software,
                billingCycle: .yearly,
                price: 7499.99,
                startDate: dateFrom(year: 2021, month: 6, day: 1),
                endDate: dateFrom(year: 2023, month: 6, day: 1),
                cancelReason: .switchedService,
                lastUsedDate: dateFrom(year: 2023, month: 4, day: 15),
                notes: "Affinity Suite'e geçtim.",
                createdAt: dateFrom(year: 2021, month: 6, day: 1)
            ),
            Subscription(
                name: "Audible",
                category: .other,
                billingCycle: .monthly,
                price: 49.90,
                startDate: dateFrom(year: 2022, month: 12, day: 1),
                endDate: dateFrom(year: 2023, month: 9, day: 1),
                cancelReason: .trialEnded,
                lastUsedDate: dateFrom(year: 2023, month: 8, day: 22),
                notes: "Ücretsiz dönemden sonra ücret çok geldi.",
                createdAt: dateFrom(year: 2022, month: 12, day: 1)
            )
        ]

        for sub in active + graveyard {
            context.insert(sub)
        }
        try? context.save()
    }

    /// Yıl/ay/gün'den Date üreten yardımcı.
    private static func dateFrom(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        return Calendar.current.date(from: components) ?? Date()
    }
}
