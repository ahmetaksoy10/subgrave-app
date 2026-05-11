//
//  BurialView.swift
//  Subgrave
//
//  "Mezarlığa Gönder" sheet'i – iptal nedeni ve son notlar.
//

import SwiftUI

struct BurialView: View {
    @Environment(\.dismiss) private var dismiss

    let subscription: Subscription
    /// Tamamlandığında çağrılır. (reason, finalNote)
    let onConfirm: (CancelReason, String?) -> Void

    @State private var selectedReason: CancelReason = .notUsing
    @State private var finalNote: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.subgraveBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero – Veda metni
                        VStack(spacing: 8) {
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(Color.subgraveSecondary)
                            SubgraveSerifText(subscription.name, size: 28, weight: .semibold)
                                .multilineTextAlignment(.center)
                            Text("Bu yolculuk \(subscription.lifespanInDays) gün sürdü ve \(subscription.totalPaid.subgraveCurrencyShort) bıraktı.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.subgraveTextSecondary)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 12)

                        // İptal nedeni
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Veda nedeni")
                                .font(.headline)
                                .foregroundStyle(Color.subgraveText)

                            ForEach(CancelReason.allCases) { reason in
                                Button {
                                    selectedReason = reason
                                } label: {
                                    HStack {
                                        Image(systemName: reason.icon)
                                            .frame(width: 24)
                                            .foregroundStyle(
                                                selectedReason == reason
                                                    ? Color.subgraveAccent
                                                    : Color.subgraveTextSecondary
                                            )
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(reason.displayName)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Color.subgraveText)
                                            Text(reason.epitaph)
                                                .font(.caption.italic())
                                                .foregroundStyle(Color.subgraveTextSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: selectedReason == reason
                                              ? "largecircle.fill.circle"
                                              : "circle")
                                            .foregroundStyle(
                                                selectedReason == reason
                                                    ? Color.subgraveAccent
                                                    : Color.subgraveGrave
                                            )
                                    }
                                    .padding()
                                    .background(
                                        selectedReason == reason
                                            ? Color.subgraveAccent.opacity(0.08)
                                            : Color.subgraveCard
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(
                                                selectedReason == reason
                                                    ? Color.subgraveAccent.opacity(0.4)
                                                    : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Son not
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Son sözler")
                                .font(.headline)
                                .foregroundStyle(Color.subgraveText)
                            TextField("İstersen bir veda notu bırak…", text: $finalNote, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.subgraveCard)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        Spacer(minLength: 12)

                        // Onay
                        Button {
                            onConfirm(selectedReason, finalNote.isEmpty ? nil : finalNote)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "leaf.fill")
                                Text("Huzura Erdir")
                            }
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.subgraveAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.subgraveAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Mezarlığa Gönder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }
}
