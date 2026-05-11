//
//  SubgraveSerifText.swift
//  Subgrave
//
//  Cormorant Garamond projeye eklenmediyse SF Pro Serif fallback kullanılır.
//  Bu sarmalayıcı sayesinde fontun custom hali sonradan tek noktada eklenebilir.
//

import SwiftUI

struct SubgraveSerifText: View {
    let text: String
    var size: CGFloat = 28
    var weight: Font.Weight = .semibold

    init(_ text: String, size: CGFloat = 28, weight: Font.Weight = .semibold) {
        self.text = text
        self.size = size
        self.weight = weight
    }

    var body: some View {
        Text(text)
            // Sistem serif fontu – Cormorant Garamond proje fontu olarak eklenirse
            // burayı .custom("CormorantGaramond-SemiBold", size: size) yap.
            .font(.system(size: size, weight: weight, design: .serif))
            .foregroundStyle(Color.subgraveText)
    }
}

/// Genel olarak uygulamanın kart stilini standart hâle getiren modifier.
struct SubgraveCardModifier: ViewModifier {
    var background: Color = .subgraveCard
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding()
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func subgraveCard(
        background: Color = .subgraveCard,
        cornerRadius: CGFloat = 20
    ) -> some View {
        modifier(SubgraveCardModifier(background: background, cornerRadius: cornerRadius))
    }
}
