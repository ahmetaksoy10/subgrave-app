//
//  TombstoneView.swift
//  Subgrave
//
//  Tek bir mezar taşı kartı.
//

import SwiftUI

struct TombstoneView: View {
    let subscription: Subscription
    var onResurrect: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            tombstoneBody
            // Aksiyon butonları, mezarın altında.
            HStack(spacing: 12) {
                Button {
                    onResurrect()
                } label: {
                    Label("Dirilt", systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.subgraveAccent.opacity(0.15))
                        .foregroundStyle(Color.subgraveAccent)
                        .clipShape(Capsule())
                }
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Kaldır", systemImage: "trash")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.subgraveAlert.opacity(0.1))
                        .foregroundStyle(Color.subgraveAlert)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
        }
    }

    // MARK: - Tombstone
    private var tombstoneBody: some View {
        ZStack {
            // Mermer/taş gradient
            TombstoneShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.subgraveStoneLight,
                            Color.subgraveStoneMid
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    TombstoneShape()
                        .stroke(Color.subgraveStoneDark.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 6)

            // İçerik – kazınmış yazı efekti gri tonlarda
            VStack(spacing: 8) {
                Spacer().frame(height: 8)
                Image(systemName: subscription.isResurrected ? "sparkles" : "leaf.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.subgraveStoneDark)
                SubgraveSerifText(subscription.name, size: 22, weight: .semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                Text("\(subscription.startDate.subgraveYear) – \(subscription.endDate?.subgraveYear ?? "?")")
                    .font(.system(.subheadline, design: .serif).weight(.medium))
                    .foregroundStyle(Color.subgraveStoneDark)

                Divider()
                    .frame(width: 60)
                    .overlay(Color.subgraveStoneDark.opacity(0.4))
                    .padding(.vertical, 2)

                // Epitaf
                if let reason = subscription.cancelReason {
                    Text("«\(reason.epitaph)»")
                        .font(.system(.footnote, design: .serif).italic())
                        .foregroundStyle(Color.subgraveStoneDark)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                // İstatistikler
                VStack(spacing: 4) {
                    statRow(label: "Yaşam süresi", value: "\(subscription.lifespanInDays) gün")
                    statRow(label: "Toplam ödeme", value: subscription.totalPaid.subgraveCurrencyShort)
                }
                .padding(.horizontal, 24)

                if subscription.isResurrected {
                    Text("Diriliş etiketli")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.subgraveAccent.opacity(0.18))
                        .foregroundStyle(Color.subgraveAccent)
                        .clipShape(Capsule())
                }

                Spacer().frame(height: 18)
            }
            .padding(.top, 24)
        }
        .frame(width: 220, height: 320)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.subgraveStoneDark.opacity(0.8))
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.subgraveStoneDark)
        }
    }
}
