//
//  SubscriptionCategory.swift
//  Subgrave
//
//  Bir aboneliğin türünü tarif eden enum.
//  SF Symbol ikonu ve görüntü adı içerir.
//

import Foundation
import SwiftUI

enum SubscriptionCategory: String, CaseIterable, Codable, Identifiable {
    case music
    case video
    case software
    case gaming
    case news
    case fitness
    case cloud
    case other

    var id: String { rawValue }

    /// Türkçe görüntü adı.
    var displayName: String {
        switch self {
        case .music:    return "Müzik"
        case .video:    return "Video"
        case .software: return "Yazılım"
        case .gaming:   return "Oyun"
        case .news:     return "Haber"
        case .fitness:  return "Fitness"
        case .cloud:    return "Bulut"
        case .other:    return "Diğer"
        }
    }

    /// SF Symbol ikon adı.
    var icon: String {
        switch self {
        case .music:    return "music.note"
        case .video:    return "play.rectangle.fill"
        case .software: return "wrench.and.screwdriver.fill"
        case .gaming:   return "gamecontroller.fill"
        case .news:     return "newspaper.fill"
        case .fitness:  return "figure.run"
        case .cloud:    return "cloud.fill"
        case .other:    return "square.grid.2x2.fill"
        }
    }

    /// Kategori için pastel arka plan vurgusu.
    var tint: Color {
        switch self {
        case .music:    return Color(hex: "#fbcfe8") // pembe
        case .video:    return Color(hex: "#fecaca") // mercan
        case .software: return Color(hex: "#bae6fd") // bebek mavisi
        case .gaming:   return Color(hex: "#ddd6fe") // lavanta
        case .news:     return Color(hex: "#fde68a") // kum sarısı
        case .fitness:  return Color(hex: "#bbf7d0") // nane
        case .cloud:    return Color(hex: "#e0e7ff") // gök
        case .other:    return Color(hex: "#e7e5e4") // kül
        }
    }
}
