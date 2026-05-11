//
//  UpcomingRenewalsView.swift
//  Subgrave
//
//  Önümüzdeki 30 günde yenilenecek aboneliklerin küçük kartı.
//

import SwiftUI

struct UpcomingRenewalsView: View {
    let renewals: [Subscription]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(Color.subgraveSecondary)
                Text("Bu Ay Yenilenecekler")
                    .font(.headline)
                    .foregroundStyle(Color.subgraveText)
                Spacer()
                Text("\(renewals.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.subgraveSecondary.opacity(0.15))
                    .clipShape(Capsule())
                    .foregroundStyle(Color.subgraveSecondary)
            }
            if renewals.isEmpty {
                Text("Sıradaki yenilemeler için henüz vakit var. Cüzdanın nefes alıyor.")
                    .font(.subheadline)
                    .foregroundStyle(Color.subgraveTextSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(renewals) { sub in
                    HStack(spacing: 12) {
                        Image(systemName: sub.category.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.subgraveText)
                            .frame(width: 32, height: 32)
                            .background(sub.category.tint)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(sub.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.subgraveText)
                            if let days = sub.daysUntilRenewal {
                                Text(days == 0 ? "Bugün yenileniyor"
                                     : days == 1 ? "Yarın yenileniyor"
                                     : "\(days) gün sonra")
                                    .font(.caption)
                                    .foregroundStyle(Color.subgraveTextSecondary)
                            }
                        }
                        Spacer()
                        Text(sub.price.subgraveCurrency)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.subgraveText)
                    }
                    if sub.id != renewals.last?.id {
                        Divider().opacity(0.4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .subgraveCard()
    }
}
