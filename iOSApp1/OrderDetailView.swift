import SwiftUI

struct OrderDetailView: View {
    @EnvironmentObject private var store: OrderStore
    @Environment(\.dismiss) private var dismiss
    let person: Person

    @State private var working: Order = Order()
    @State private var showSuccess: Bool = false
    @State private var confirmClearSubmitted: Bool = false
    @State private var confirmClearCurrent: Bool = false

    private var isUpdatingExisting: Bool { person.lastOrder != nil }

    var body: some View {
        Form {
            // MARK: Drink
            Section("Drink") {
                Picker("Type", selection: $working.drink) {
                    ForEach(DrinkType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                Picker("Size", selection: $working.size) {
                    ForEach(CupSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                Toggle("Decaf", isOn: $working.decaf)
                Toggle("Iced", isOn: $working.iced)
            }

            // MARK: Customize
            Section("Customize") {
                Stepper("Sugars: \(working.sugars)", value: $working.sugars, in: 0...6)
                Stepper("Milks/Cream: \(working.milks)", value: $working.milks, in: 0...6)
                TextField("Notes (e.g., lactose free)", text: $working.notes)
            }

            // MARK: Actions
            Section {
                // Save Favorite (centered)
                centeredRowButton(title: "Save as Favorite", style: .bordered) {
                    store.saveFavorite(for: person, order: working)
                    Haptics.success()
                }

                // Load Favorite (if any)
                if person.favorite != nil {
                    centeredRowButton(title: "Use Favorite", style: .bordered) {
                        if let fav = person.favorite { working = fav }
                        Haptics.success()
                    }
                }

                // Load Last Order (explicit "modify" entry point)
                if person.lastOrder != nil {
                    centeredRowButton(title: "Load Submitted Order", style: .bordered) {
                        if let last = person.lastOrder { working = last }
                        Haptics.success()
                    }
                }

                // Clear current selections (keeps submitted history)
                centeredRowButton(title: "Clear Current Selections", style: .bordered) {
                    confirmClearCurrent = true
                }
                .confirmationDialog("Clear current selections?", isPresented: $confirmClearCurrent, titleVisibility: .visible) {
                    Button("Clear", role: .destructive) {
                        working = Order()
                        store.clearDraft(for: person)
                        Haptics.success()
                    }
                    Button("Cancel", role: .cancel) {}
                }

                // Submit / Update (perfectly centered text)
                centeredProminentButton(title: isUpdatingExisting ? "Update Order" : "Place Order") {
                    // ensure a draft exists even if user didn’t change anything
                    store.updateDraft(for: person, order: working)
                    store.submitOrder(for: person)
                    Haptics.success()
                    showSuccess = true
                }

                // Clear the submitted order (history) — optional destructive
                if person.lastOrder != nil {
                    centeredRowButton(title: "Clear Submitted Order", style: .bordered) {
                        confirmClearSubmitted = true
                    }
                    .tint(.red)
                    .confirmationDialog("Clear submitted order for \(person.name)?", isPresented: $confirmClearSubmitted, titleVisibility: .visible) {
                        Button("Clear Submitted Order", role: .destructive) {
                            store.clearLastOrder(for: person)
                            // Also reset the working UI to defaults so user starts fresh
                            working = store.draftOrder(for: person)
                            Haptics.success()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            } footer: {
                Text("Tip: Tap “Load Submitted Order” to modify what was saved previously, then tap “Update Order”.")
            }
        }
        .navigationTitle(person.name)
        .onAppear {
            // Start from a sensible draft and register it so submit always works
            working = store.draftOrder(for: person)
            store.updateDraft(for: person, order: working)
        }
        .onChange(of: working) { newValue in
            store.updateDraft(for: person, order: newValue)
        }
        .alert(isUpdatingExisting ? "Order updated successfully" : "Order submitted successfully",
               isPresented: $showSuccess) {
            Button("OK") {
                // If you want to automatically go back to the list:
                // dismiss()
            }
        } message: {
            Text("\(person.name)’s \(working.size.rawValue) \(working.drink.rawValue) has been saved.")
        }
    }

    // MARK: - Perfectly centered buttons inside Form rows

    /// A helper that creates a *prominent* full-width, truly centered button inside a Form row.
    /// Uses Spacer–Text–Spacer so even with Form row layout, the label is visually centered.
    @ViewBuilder
    private func centeredProminentButton(title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Spacer(minLength: 0)
            Button(action: action) {
                // TEXT-ONLY to avoid icon shifting; bolded; centered by Spacers
                Text(title).fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Spacer(minLength: 0)
        }
        // Remove default left inset so the visual width is truly full width
        .listRowInsets(EdgeInsets())
    }

    /// A helper that creates a bordered full-width centered button.
    @ViewBuilder
    private func centeredRowButton(title: String, style: ButtonStyleType = .bordered, action: @escaping () -> Void) -> some View {
        HStack {
            Spacer(minLength: 0)
            Button(action: action) {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .buttonStyle(style == .bordered ? .bordered : .borderless)
            .controlSize(.large)
            Spacer(minLength: 0)
        }
        .listRowInsets(EdgeInsets())
    }

    private enum ButtonStyleType { case bordered, borderless }
}

#Preview {
    OrderDetailView(person: Person(name: "Preview"))
        .environmentObject(OrderStore())
}
