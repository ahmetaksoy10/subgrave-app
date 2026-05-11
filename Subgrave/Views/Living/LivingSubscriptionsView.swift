//
//  LivingSubscriptionsView.swift
//  Subgrave
//
//  Aktif abonelikler ekranı – arama, filtre, sıralama, swipe.
//

import SwiftUI
import SwiftData

struct LivingSubscriptionsView: View {
    @State private var viewModel: SubscriptionListViewModel
    @State private var burying: Subscription?
    @State private var editing: Subscription?
    @State private var showingAdd = false
    @Environment(\.modelContext) private var modelContext

    init(repository: SubscriptionRepositoryProtocol) {
        _viewModel = State(initialValue: SubscriptionListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.subgraveBackground.ignoresSafeArea()

                if viewModel.filtered.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Toplam aylık özet
                            summaryStrip

                            ForEach(viewModel.filtered) { sub in
                                SubscriptionCardView(
                                    subscription: sub,
                                    onBury: { burying = sub },
                                    onMarkUsed: { viewModel.markAsUsedNow(sub) },
                                    onEdit: { editing = sub }
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.filtered.map(\.id))
                    }
                }
            }
            .navigationTitle("Yaşayanlar")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Abonelik ara")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Sıralama") {
                            ForEach(SortOption.allCases) { option in
                                Button {
                                    viewModel.sortOption = option
                                } label: {
                                    Label(option.displayName, systemImage: option.icon)
                                }
                            }
                        }
                        Section("Kategori") {
                            Button("Tümü") { viewModel.selectedCategory = nil }
                            ForEach(SubscriptionCategory.allCases) { cat in
                                Button {
                                    viewModel.selectedCategory = cat
                                } label: {
                                    Label(cat.displayName, systemImage: cat.icon)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(Color.subgraveAccent)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.subgraveAccent)
                    }
                }
            }
            .sheet(item: $burying, onDismiss: { viewModel.load() }) { sub in
                BurialView(subscription: sub) { reason, note in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        viewModel.sendToGraveyard(sub, reason: reason, finalNote: note)
                    }
                }
            }
            .sheet(item: $editing, onDismiss: { viewModel.load() }) { sub in
                AddSubscriptionView(
                    repository: SwiftDataSubscriptionRepository(modelContext: modelContext),
                    editing: sub
                )
            }
            .sheet(isPresented: $showingAdd, onDismiss: { viewModel.load() }) {
                AddSubscriptionView(
                    repository: SwiftDataSubscriptionRepository(modelContext: modelContext)
                )
            }
            .onAppear { viewModel.load() }
        }
    }

    // MARK: - Summary
    private var summaryStrip: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Aylık toplam")
                    .font(.caption)
                    .foregroundStyle(Color.subgraveTextSecondary)
                Text(viewModel.totalMonthlyExpense.subgraveCurrency)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.subgraveText)
            }
            Spacer()
            if viewModel.ghostCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("\(viewModel.ghostCount) hayalet")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color.subgraveAlert)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.subgraveAlert.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color.subgraveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 56))
                .foregroundStyle(Color.subgraveLiving)
            Text("Bahçe henüz boş")
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(Color.subgraveText)
            Text("İlk aboneliğini eklediğinde burada nefes almaya başlayacak.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.subgraveTextSecondary)
                .padding(.horizontal, 32)
            Button {
                showingAdd = true
            } label: {
                Label("Abonelik Ekle", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.subgraveAccent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
    }
}
