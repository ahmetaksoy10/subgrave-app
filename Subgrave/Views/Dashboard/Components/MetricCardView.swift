//
//  MetricCardView.swift
//  Subgrave
//
//  Ana sayfanın üstünde duran 4 metrik kartından biri.
//

import SwiftUI

struct MetricCardView: View {
    let title: String
    let value: String
    let icon: String
    var tint: Color = .subgraveAccent
    var emphasized: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 32, height: 32)
                    .background(tint.opacity(0.15))
                    .clipShape(Circle())
                Spacer()
            }
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(emphasized ? Color.subgraveAlert : Color.subgraveText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.subgraveTextSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .subgraveCard()
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        MetricCardView(title: "Aktif Abonelik", value: "5", icon: "leaf.fill", tint: .green)
        MetricCardView(title: "Aylık Toplam", value: "₺387,86", icon: "creditcard.fill", tint: .subgraveAccent)
        MetricCardView(title: "Mezarlıkta", value: "₺2.340,50", icon: "moon.stars.fill", tint: .subgraveSecondary)
        MetricCardView(title: "Hayalet Uyarısı", value: "1", icon: "exclamationmark.triangle.fill", tint: .subgraveAlert, emphasized: true)
    }
    .padding()
    .background(Color.subgraveBackground)
}
