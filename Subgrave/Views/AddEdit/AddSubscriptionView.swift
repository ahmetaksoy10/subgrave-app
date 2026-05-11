//
//  AddSubscriptionView.swift
//  Subgrave
//
//  Yeni abonelik ekleme veya düzenleme formu.
//

import SwiftUI

struct AddSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddSubscriptionViewModel
    @State private var showTemplates = false

    init(repository: SubscriptionRepositoryProtocol, editing: Subscription? = nil) {
        _viewModel = State(initialValue: AddSubscriptionViewModel(repository: repository, editing: editing))
    }

    var body: some View {
        NavigationStack {
            Form {
                if !viewModel.isEditing {
                    Section {
                        Button {
                            showTemplates = true
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Hazır şablonlardan seç")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                            }
                            .foregroundStyle(Color.subgraveAccent)
                        }
                    }
                }

                Section("Abonelik") {
                    TextField("Ad (örn. Spotify)", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                    Picker("Kategori", selection: $viewModel.category) {
                        ForEach(SubscriptionCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }

                Section("Ücret") {
                    Picker("Periyot", selection: $viewModel.billingCycle) {
                        ForEach(BillingCycle.allCases) { cycle in
                            Text(cycle.displayName).tag(cycle)
                        }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("₺")
                            .foregroundStyle(Color.subgraveTextSecondary)
                        TextField("0,00", text: $viewModel.priceText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("Tarih") {
                    DatePicker(
                        "Başlangıç tarihi",
                        selection: $viewModel.startDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .environment(\.locale, Locale(identifier: "tr_TR"))
                }

                Section("Notlar") {
                    TextField("Bir hatıra bırak…", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(Color.subgraveAlert)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.subgraveBackground)
            .navigationTitle(viewModel.formTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditing ? "Kaydet" : "Ekle") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSaving)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showTemplates) {
                TemplatePickerView { template in
                    viewModel.applyTemplate(template)
                    showTemplates = false
                }
            }
        }
    }
}

// MARK: - Template Picker
private struct TemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (SubscriptionTemplate) -> Void

    var body: some View {
        NavigationStack {
            List(AddSubscriptionViewModel.templates) { template in
                Button {
                    onSelect(template)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: template.category.icon)
                            .frame(width: 36, height: 36)
                            .background(template.category.tint)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .foregroundStyle(Color.subgraveText)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(template.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.subgraveText)
                            Text("\(template.category.displayName) · \(template.cycle.displayName)")
                                .font(.caption)
                                .foregroundStyle(Color.subgraveTextSecondary)
                        }
                        Spacer()
                        Text(template.price.subgraveCurrency)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.subgraveText)
                    }
                }
            }
            .navigationTitle("Şablonlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}
