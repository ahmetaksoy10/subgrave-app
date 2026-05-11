//
//  Color+Theme.swift
//  Subgrave
//
//  Tüm renk paleti tek bir yerden yönetilir.
//  Açık tema (sabah ışığı, huzurlu bahçe hissi).
//

import SwiftUI

extension Color {
    // MARK: - Arka Plan
    /// Krem/fildişi ana arka plan
    static let subgraveBackground = Color(hex: "#faf7f2")
    /// Saf beyaz kart arka planı
    static let subgraveCard = Color.white

    // MARK: - Aksan Renkleri
    /// Lavanta moru – ana aksan
    static let subgraveAccent = Color(hex: "#a78bfa")
    /// Şeftali – ikincil aksan
    static let subgraveSecondary = Color(hex: "#fb923c")

    // MARK: - Durum Renkleri
    /// Yaşayan abonelikler için pastel yeşil
    static let subgraveLiving = Color(hex: "#86efac")
    /// Mezarlık taş rengi
    static let subgraveGrave = Color(hex: "#d6d3d1")
    /// Mezar taşı için açık taş tonu
    static let subgraveStoneLight = Color(hex: "#efece6")
    /// Mezar taşı için orta taş tonu
    static let subgraveStoneMid = Color(hex: "#dcd6cc")
    /// Mezar taşı için koyu taş tonu (kazıma efekti)
    static let subgraveStoneDark = Color(hex: "#9ca0a3")

    // MARK: - Metin
    /// Koyu lacivert ana metin rengi
    static let subgraveText = Color(hex: "#1e293b")
    /// Daha açık ikincil metin
    static let subgraveTextSecondary = Color(hex: "#64748b")

    // MARK: - Uyarılar
    /// Gül kurusu önemli uyarılar için
    static let subgraveAlert = Color(hex: "#f43f5e")

    // MARK: - Hex Init
    /// Hex string'den Color oluşturma. Örn: Color(hex: "#a78bfa")
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch hexString.count {
        case 6: // RRGGBB
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RRGGBBAA
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
