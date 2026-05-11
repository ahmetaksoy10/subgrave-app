//
//  TombstoneShape.swift
//  Subgrave
//
//  Mezar taşı için custom Shape – yuvarlatılmış üst, düz alt.
//

import SwiftUI

struct TombstoneShape: Shape {
    /// Üst yuvarlağın yarıçapı, kart genişliğine bağlı.
    var topRadiusFactor: CGFloat = 0.5

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = rect.width * topRadiusFactor

        // Sol alt köşe.
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Yukarı çık (yuvarlağın başlangıcına).
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        // Yarım daire üst.
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        // Sağ aşağı.
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
