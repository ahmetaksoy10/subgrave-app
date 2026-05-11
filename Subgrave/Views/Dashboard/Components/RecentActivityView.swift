//
//  RecentActivityView.swift
//  Subgrave
//
//  Son aktivite akışı – yeni eklenenler ve mezarlığa gönderilenler.
//

import SwiftUI

struct RecentActivityView: View {
    let items: [ActivityItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(Color.subgraveAccent)
                Text("Son Aktivite")
                    .font(.headline)
                    .foregroundStyle(Color.subgraveText)
                Spacer()
            }
            if items.isEmpty {
                Text("Daha hiç hareket yok. Henüz kimse doğmadı, kimse defnedilmedi.")
                    .font(.subheadline)
                    .foregroundStyle(Color.subgraveTextSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.kind == .added ? "sparkles" : "leaf")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(item.kind == .added ? Color.subgraveLiving : Color.subgraveGrave)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.kind == .added
                                 ? "\(item.subscription.name) yaşamaya başladı"
                                 : "\(item.subscription.name) huzura erdi")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.subgraveText)
                            Text(item.date.relativeFromNow)
                                .font(.caption)
                                .foregroundStyle(Color.subgraveTextSecondary)
                        }
                        Spacer()
                    }
                    if item.id != items.last?.id {
                        Divider().opacity(0.4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .subgraveCard()
    }
}
