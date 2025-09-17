import SwiftUI

struct OrderDetailView: View {
    @EnvironmentObject private var store: OrderStore
    @Environment(\.dismiss) private var dismiss   // optional, if you want to pop after OK
    let person: Person

    @State private var working: Order = Order()
    @State private var showSuccess: Bool = false

    var body: some View {
        Form {
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

            Section("Customize") {
                Stepper("Sugars: \(working.sugars)", value: $working.sugars, in: 0...6)
                Stepper("Milks/Cream: \(working.milks)", value: $working.milks, in: 0...6)
                TextField("Notes (e.g., lactose free)", text: $working.notes)
            }

            Section {
                Button {
                    store.saveFavorite(for: person, order: working)
                } label: {
                    Text("Save as Favorite")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.bordered)

                if person.favorite != nil {
                    Button {
                        if let fav = person.favorite { working = fav }
                    } label: {
                        Text("Use Favorite")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    // ensure a draft exists even if user didn't change anything
                    store.updateDraft(for: person, order: working)
                    store.submitOrder(for: person)
                    showSuccess = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Place Order", systemImage: "checkmark.circle.fill")
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } footer: {
                Text("Placing the order sets this as \(person.name)’s latest order.")
            }
        }
        .navigationTitle(person.name)
        .onAppear {
            // start from a sensible draft and register it so submit always works
            working = store.draftOrder(for: person)
            store.updateDraft(for: person, order: working)
        }
        .onChange(of: working) { newValue in
            store.updateDraft(for: person, order: newValue)
        }
        .alert("Order submitted successfully", isPresented: $showSuccess) {
            Button("OK") {
                // Optional: go back after confirming
                // dismiss()
            }
        } message: {
            Text("\(person.name)’s \(working.size.rawValue) \(working.drink.rawValue) has been saved.")
        }
    }
}

#Preview {
    OrderDetailView(person: Person(name: "Preview"))
        .environmentObject(OrderStore())
}
