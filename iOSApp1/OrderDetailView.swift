import SwiftUI

struct OrderDetailView: View {
    @EnvironmentObject private var store: OrderStore
    @Environment(\.dismiss) private var dismiss
    let person: Person

    // Selections start as nil so we can show "Select ..." placeholders
    @State private var selectedDrink: DrinkType? = nil
    @State private var selectedSize:  CupSize?   = nil

    // Other fields can keep defaults
    @State private var working: Order = Order()

    @State private var showSubmitted: Bool = false
    @State private var showUpdated:   Bool = false
    @State private var confirmClear:  Bool = false

    // Look up the live Person in the store so UI reacts to changes
    private var livePerson: Person? {
        store.people.first(where: { $0.id == person.id })
    }
    private var hasSavedOrder: Bool {
        (livePerson?.lastOrder) != nil
    }
    private var canSubmitNew: Bool {
        selectedDrink != nil && selectedSize != nil
    }

    var body: some View {
        Form {
            // MARK: Drink (Pickers with "Select ..." placeholders)
            Section("Drink") {
                Picker("Type", selection: $selectedDrink) {
                    Text("Select Type").tag(DrinkType?.none) // placeholder
                    ForEach(DrinkType.allCases) { type in
                        Text(type.rawValue).tag(Optional(type))
                    }
                }
                Picker("Size", selection: $selectedSize) {
                    Text("Select Size").tag(CupSize?.none) // placeholder
                    ForEach(CupSize.allCases) { size in
                        Text(size.rawValue).tag(Optional(size))
                    }
                }
                Toggle("Decaf", isOn: $working.decaf)
                Toggle("Iced",  isOn: $working.iced)
            }

            // MARK: Customize
            Section("Customize") {
                Stepper("Sugars: \(working.sugars)", value: $working.sugars, in: 0...6)
                Stepper("Milks/Cream: \(working.milks)", value: $working.milks, in: 0...6)
                TextField("Notes (e.g., lactose free)", text: $working.notes)
            }

            // MARK: Actions (exactly 3)
            Section {
                // 1) Place Order (only when no saved order yet)
                if !hasSavedOrder {
                    wideFilledButton("Place Order", disabled: !canSubmitNew) {
                        // write chosen values into the order
                        if let d = selectedDrink { working.drink = d }
                        if let s = selectedSize  { working.size  = s }
                        store.updateDraft(for: person, order: working)
                        store.submitOrder(for: person)
                        showSubmitted = true
                    }
                }

                // 2) Update Order (shown when a saved order exists)
                if hasSavedOrder {
                    wideFilledButton("Update Order", disabled: !(selectedDrink != nil && selectedSize != nil)) {
                        if let d = selectedDrink { working.drink = d }
                        if let s = selectedSize  { working.size  = s }
                        store.updateDraft(for: person, order: working)
                        store.submitOrder(for: person)
                        showUpdated = true
                    }
                }

                // 3) Clear Order (remove saved order and reset UI)
                wideOutlineButton("Clear Order", disabled: !hasSavedOrder) {
                    confirmClear = true
                }
                .confirmationDialog("Clear submitted order for \(person.name)?",
                                    isPresented: $confirmClear, titleVisibility: .visible) {
                    Button("Clear Order", role: .destructive) {
                        store.clearLastOrder(for: person)
                        store.clearDraft(for: person)
                        resetToPlaceholders()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            } footer: {
                Text(!hasSavedOrder
                     ? "Choose a Type and a Size to enable Place Order."
                     : "Change Type/Size or other options, then tap Update Order. Use Clear Order to remove it.")
            }
        }
        .navigationTitle(person.name)

        // keep Order in sync if user picks the values later
        .onChange(of: selectedDrink) { if let d = $0 { working.drink = d } }
        .onChange(of: selectedSize)  { if let s = $0 { working.size  = s } }

        .onAppear { configureInitialState() }

        // Alerts
        .alert("Order submitted successfully", isPresented: $showSubmitted) {
            Button("OK") { /* dismiss() if you want */ }
        } message: {
            Text("\(person.name)’s \(working.size.rawValue) \(working.drink.rawValue) has been saved.")
        }
        .alert("Order updated successfully", isPresented: $showUpdated) {
            Button("OK") { /* dismiss() if you want */ }
        } message: {
            Text("\(person.name)’s order has been updated.")
        }
    }

    // MARK: - Initial/Reset helpers
    private func configureInitialState() {
        // Start with any existing draft to keep sugars/milk/notes
        working = store.draftOrder(for: person)

        if let last = livePerson?.lastOrder {
            // Existing order: preselect so Update is enabled immediately
            selectedDrink = last.drink
            selectedSize  = last.size
        } else {
            // New order: force placeholders until user chooses
            selectedDrink = nil
            selectedSize  = nil
        }
        // Keep draft in store in sync
        store.updateDraft(for: person, order: working)
    }

    private func resetToPlaceholders() {
        working = Order()
        selectedDrink = nil
        selectedSize  = nil
    }

    // MARK: - Simple centered buttons (SDK-friendly, no modern .buttonStyle shorthands)
    @ViewBuilder
    private func wideFilledButton(_ title: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        HStack {
            Spacer(minLength: 0)
            Button(action: action) {
                Text(title).font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .background(disabled ? Color.gray.opacity(0.4) : Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(disabled)
            .buttonStyle(.plain)
            Spacer(minLength: 0)
        }
        .listRowInsets(EdgeInsets())
        .opacity(disabled ? 0.8 : 1.0)
    }

    @ViewBuilder
    private func wideOutlineButton(_ title: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        HStack {
            Spacer(minLength: 0)
            Button(action: action) {
                Text(title).font(.headline)
                    .foregroundColor(disabled ? .gray : .accentColor)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(disabled ? Color.gray.opacity(0.6) : Color.accentColor, lineWidth: 1)
                    )
            }
            .disabled(disabled)
            .buttonStyle(.plain)
            Spacer(minLength: 0)
        }
        .listRowInsets(EdgeInsets())
        .opacity(disabled ? 0.6 : 1.0)
    }
}

#Preview {
    OrderDetailView(person: Person(name: "Preview"))
        .environmentObject(OrderStore())
}
