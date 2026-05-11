//
//  NotificationService.swift
//  Subgrave
//
//  Yenileme tarihinden 3 gün önce yerel bildirim planlar.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    /// Bildirim izni ister.
    func requestAuthorization() async {
        do {
            _ = try await UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            // Sessizce yut – kullanıcı izin vermek zorunda değil.
            print("Bildirim izin hatası: \(error)")
        }
    }

    /// Verilen abonelik için yenilemeden 3 gün önce bildirim planlar.
    /// İzin daha önce alınmadıysa kibarca ister.
    func scheduleRenewalReminder(for subscription: Subscription) {
        Task { await ensureAuthorized() }
        guard let renewal = subscription.nextRenewalDate else { return }
        let triggerDate = Calendar.current.date(byAdding: .day, value: -3, to: renewal) ?? renewal
        guard triggerDate > Date() else { return } // Geçmiş bildirime gerek yok

        let content = UNMutableNotificationContent()
        content.title = "\(subscription.name) yenilenmek üzere"
        content.body = "\(renewal.subgraveLongFormat) tarihinde \(subscription.price.subgraveCurrency) çekilecek. Hâlâ kullanıyor musun?"
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "renewal-\(subscription.id.uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    /// İzin verilmemişse soru sor; verilmişse sessizce devam et.
    private func ensureAuthorized() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            await requestAuthorization()
        }
    }

    /// Aboneliğin tüm planlanmış bildirimlerini iptal eder.
    func cancelReminder(for subscription: Subscription) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["renewal-\(subscription.id.uuidString)"])
    }
}
