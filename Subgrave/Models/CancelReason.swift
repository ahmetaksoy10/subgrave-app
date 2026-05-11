//
//  CancelReason.swift
//  Subgrave
//
//  Bir aboneliğin neden mezarlığa gönderildiğini tarif eden enum.
//

import Foundation

enum CancelReason: String, CaseIterable, Codable, Identifiable {
    case priceIncrease
    case notUsing
    case switchedService
    case trialEnded
    case other

    var id: String { rawValue }

    /// Kullanıcıya gösterilecek Türkçe gerekçe.
    var displayName: String {
        switch self {
        case .priceIncrease:   return "Fiyat arttı"
        case .notUsing:        return "Kullanmıyorum"
        case .switchedService: return "Başka servise geçtim"
        case .trialEnded:      return "Deneme süresi bitti"
        case .other:           return "Diğer"
        }
    }

    /// Mezar taşının üzerine yazılacak şefkatli kısa epitaf.
    var epitaph: String {
        switch self {
        case .priceIncrease:   return "Cüzdana ağır geldi"
        case .notUsing:        return "Unutulup gitti"
        case .switchedService: return "Başka kapı çaldı"
        case .trialEnded:      return "Misafirliği bitti"
        case .other:           return "Vakti gelmişti"
        }
    }

    /// SF Symbol ikon.
    var icon: String {
        switch self {
        case .priceIncrease:   return "arrow.up.circle.fill"
        case .notUsing:        return "moon.zzz.fill"
        case .switchedService: return "arrow.triangle.swap"
        case .trialEnded:      return "hourglass.bottomhalf.filled"
        case .other:           return "leaf.fill"
        }
    }
}
