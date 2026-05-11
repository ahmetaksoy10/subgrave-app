//
//  Subscription.swift
//  Subgrave
//
//  Ana veri modeli. SwiftData @Model olarak işaretlendi.
//  endDate == nil → abonelik aktif (yaşıyor)
//  endDate != nil → abonelik mezarlıkta
//

import Foundation
import SwiftData

@Model
final class Subscription {
    /// Benzersiz tanımlayıcı.
    var id: UUID
    /// Abonelik adı (örn. "Spotify").
    var name: String
    /// Kategori (raw value olarak saklanır).
    var categoryRaw: String
    /// Faturalandırma periyodu (raw).
    var billingCycleRaw: String
    /// Tek dönem tutarı (TL). Eğer billingCycle yıllık ise bu yıllık tutar.
    var price: Double
    /// Aboneliğin başladığı tarih.
    var startDate: Date
    /// Aboneliğin sonlandığı tarih. nil → aktif.
    var endDate: Date?
    /// İptal nedeni (raw).
    var cancelReasonRaw: String?
    /// Son kullanım tarihi (kullanım sıklığı / hayalet tespiti için).
    var lastUsedDate: Date?
    /// Kullanıcı notları.
    var notes: String
    /// Aynı abonelik daha önce iptal edilip tekrar başlatıldıysa true.
    var isResurrected: Bool
    /// Eklenme zamanı (sıralama için).
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: SubscriptionCategory,
        billingCycle: BillingCycle = .monthly,
        price: Double,
        startDate: Date,
        endDate: Date? = nil,
        cancelReason: CancelReason? = nil,
        lastUsedDate: Date? = nil,
        notes: String = "",
        isResurrected: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = category.rawValue
        self.billingCycleRaw = billingCycle.rawValue
        self.price = price
        self.startDate = startDate
        self.endDate = endDate
        self.cancelReasonRaw = cancelReason?.rawValue
        self.lastUsedDate = lastUsedDate
        self.notes = notes
        self.isResurrected = isResurrected
        self.createdAt = createdAt
    }
}

// MARK: - Computed Properties
extension Subscription {
    /// SwiftData'dan dönen raw değerleri tipli enum'a çevir.
    var category: SubscriptionCategory {
        get { SubscriptionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var billingCycle: BillingCycle {
        get { BillingCycle(rawValue: billingCycleRaw) ?? .monthly }
        set { billingCycleRaw = newValue.rawValue }
    }

    var cancelReason: CancelReason? {
        get { cancelReasonRaw.flatMap(CancelReason.init(rawValue:)) }
        set { cancelReasonRaw = newValue?.rawValue }
    }

    /// Yaşıyor mu? (endDate yok = aktif).
    var isActive: Bool { endDate == nil }

    /// Aylık eşdeğer maliyet — yıllık aboneliği 12'ye böler.
    var monthlyEquivalent: Double {
        switch billingCycle {
        case .monthly: return price
        case .yearly:  return price / 12.0
        }
    }

    /// Aboneliğin başlangıçtan bugüne (veya iptal tarihine) kadar geçen gün sayısı.
    var lifespanInDays: Int {
        let end = endDate ?? Date()
        return startDate.days(until: end)
    }

    /// Kaç ay yaşadı (yaklaşık).
    var lifespanInMonths: Int {
        let end = endDate ?? Date()
        return startDate.months(until: end)
    }

    /// Şu ana kadar toplam ödenen tutar (yaklaşık).
    /// Aylık ücret × yaşadığı ay sayısı.
    var totalPaid: Double {
        let months = max(1, lifespanInMonths)
        return monthlyEquivalent * Double(months)
    }

    /// 30 gün veya daha uzun süredir kullanılmamış aktif abonelik.
    var isGhost: Bool {
        guard isActive else { return false }
        guard let lastUsed = lastUsedDate else {
            // Hiç kullanım kaydı yoksa ve 30 günden fazla aktifse hayalet.
            return lifespanInDays >= 30
        }
        return lastUsed.days(until: Date()) >= 30
    }

    /// Bir sonraki yenileme tarihi (aktif abonelikler için).
    var nextRenewalDate: Date? {
        guard isActive else { return nil }
        let calendar = Calendar.current
        var next = startDate
        let now = Date()
        let component: Calendar.Component = (billingCycle == .monthly) ? .month : .year
        // Bugünden sonraki ilk yenileme tarihine kadar ileri sar.
        while next <= now {
            guard let advanced = calendar.date(byAdding: component, value: 1, to: next) else { break }
            next = advanced
        }
        return next
    }

    /// Yenilemeye kalan gün sayısı.
    var daysUntilRenewal: Int? {
        guard let next = nextRenewalDate else { return nil }
        return Date().days(until: next)
    }

    /// Kullanım sıklığı – kabaca "yoğun / orta / az".
    var usageFrequencyLabel: String {
        guard let lastUsed = lastUsedDate else { return "Henüz kullanılmadı" }
        let days = lastUsed.days(until: Date())
        switch days {
        case ..<3:  return "Sık kullanılıyor"
        case 3..<14: return "Orta sıklıkta"
        case 14..<30: return "Az kullanılıyor"
        default:     return "Uzun süredir uyuyor"
        }
    }
}
