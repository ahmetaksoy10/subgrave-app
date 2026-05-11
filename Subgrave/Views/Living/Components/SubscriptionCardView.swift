//
//  SubscriptionCardView.swift
//  Subgrave
//
//  Yaşayan abonelik için kart görünümü.
//

import SwiftUI
import UIKit

struct SubscriptionCardView: View {
    let subscription: Subscription
    var onBury: () -> Void
    var onMarkUsed: () -> Void
    var onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: subscription.category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.subgraveText)
                    .frame(width: 44, height: 44)
                    .background(subscription.category.tint)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(subscription.name)
                            .font(.system(.title3, design: .serif).weight(.semibold))
                            .foregroundStyle(Color.subgraveText)
                        if subscription.isResurrected {
                            Text("Diriliş")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.subgraveAccent.opacity(0.15))
                                .foregroundStyle(Color.subgraveAccent)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subscription.category.displayName)
                        .font(.caption)
                        .foregroundStyle(Color.subgraveTextSecondary)
                    Text(livingTagline)
                        .font(.caption.italic())
                        .foregroundStyle(Color.subgraveLiving.opacity(0.9).blending(with: .black, fraction: 0.45))
                }

                Spacer()

                if subscription.isGhost {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.subgraveAlert)
                        Text("Hayalet")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.subgraveAlert)
                    }
                }
            }

            // Bilgi satırı: ücret, sonraki ödeme, başlangıçtan beri toplam
            HStack(spacing: 0) {
                infoBlock(
                    title: "Aylık",
                    value: subscription.monthlyEquivalent.subgraveCurrency
                )
                Divider().frame(height: 28).overlay(Color.subgraveGrave)
                infoBlock(
                    title: "Sonraki ödeme",
                    value: subscription.nextRenewalDate?.subgraveShortFormat ?? "—"
                )
                Divider().frame(height: 28).overlay(Color.subgraveGrave)
                infoBlock(
                    title: "Toplam",
                    value: subscription.totalPaid.subgraveCurrencyShort
                )
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(Color.subgraveBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Kullanım sıklığı + aksiyonlar
            HStack {
                Label(subscription.usageFrequencyLabel, systemImage: "moon.zzz")
                    .font(.caption)
                    .foregroundStyle(
                        subscription.isGhost ? Color.subgraveAlert : Color.subgraveTextSecondary
                    )
                Spacer()
                Button {
                    onMarkUsed()
                } label: {
                    Label("Bugün kullandım", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.subgraveAccent)
                }
                .buttonStyle(.plain)
            }

            Button(role: .destructive) {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onBury()
            } label: {
                HStack {
                    Image(systemName: "leaf.fill")
                    Text("Mezarlığa Gönder")
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.subgraveAlert.opacity(0.1))
                .foregroundStyle(Color.subgraveAlert)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .subgraveCard()
        .contextMenu {
            Button { onEdit() } label: {
                Label("Düzenle", systemImage: "pencil")
            }
            Button { onMarkUsed() } label: {
                Label("Bugün kullandım", systemImage: "checkmark.circle")
            }
            Button(role: .destructive) {
                onBury()
            } label: {
                Label("Mezarlığa Gönder", systemImage: "leaf")
            }
        }
    }

    private var livingTagline: String {
        subscription.isGhost ? "Hayalet alarm!" : "Yaşıyor ve nefes alıyor"
    }

    private func infoBlock(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.subgraveText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.subgraveTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helpers
private extension Color {
    /// Belirli bir oranda siyahla harmanlayarak metin için biraz daha okunaklı yeşil/yumuşak ton üretir.
    func blending(with other: Color, fraction: Double) -> Color {
        // Basit bir kanıt-of-concept – gerçek lerp yerine opacity kombinasyonu.
        return self.opacity(1 - fraction)
    }
}
