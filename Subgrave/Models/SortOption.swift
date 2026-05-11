//
//  SortOption.swift
//  Subgrave
//
//  Yaşayanlar listesi için sıralama tercihleri.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case priceDescending
    case priceAscending
    case ageDescending
    case ageAscending
    case usageFrequency

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .priceDescending: return "Ücret: Yüksekten Düşüğe"
        case .priceAscending:  return "Ücret: Düşükten Yükseğe"
        case .ageDescending:   return "Yaş: En Eski Önce"
        case .ageAscending:    return "Yaş: En Yeni Önce"
        case .usageFrequency:  return "Az Kullanılanlar Önce"
        }
    }

    var icon: String {
        switch self {
        case .priceDescending: return "arrow.down"
        case .priceAscending:  return "arrow.up"
        case .ageDescending:   return "clock.arrow.circlepath"
        case .ageAscending:    return "clock"
        case .usageFrequency:  return "moon.zzz"
        }
    }
}
