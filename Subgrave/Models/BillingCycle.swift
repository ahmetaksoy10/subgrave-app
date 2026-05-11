//
//  BillingCycle.swift
//  Subgrave
//
//  Aboneliğin faturalandırma periyodu.
//

import Foundation

enum BillingCycle: String, CaseIterable, Codable, Identifiable {
    case monthly
    case yearly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .monthly: return "Aylık"
        case .yearly:  return "Yıllık"
        }
    }

    /// Bir periyotluk gün sayısı (yaklaşık).
    var approximateDays: Int {
        switch self {
        case .monthly: return 30
        case .yearly:  return 365
        }
    }
}
