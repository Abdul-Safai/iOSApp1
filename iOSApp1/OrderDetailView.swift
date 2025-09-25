import SwiftUI

struct OrderDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var store: SavedOrdersStore

  // Editing an existing order or creating a new one
  let existingOrder: PersonOrder?

  @State private var name: String = ""
  @State private var drink: THDrink = .coffee
  @State private var size: THCupSize = .medium
  @State private var milk: String = "2% milk"
  @State private var sugar: Int = 1
  @State private var notes: String = ""
  @State private var isFavorite: Bool = false

  // Validation/UI state
  @State private var isValid: Bool = false
  @FocusState private var focusedField: Bool

  init(existingOrder: PersonOrder? = nil) {
    self.existingOrder = existingOrder
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Team Member") {
          TextField("Name", text: $name)
            .focused($focusedField)
        }

        Section("Drink") {
          Picker("Type", selection: $drink) {
            ForEach(THDrink.allCases, id: \.self) { Text($0.rawValue).tag($0) }
          }
          Picker("Size", selection: $size) {
            ForEach(THCupSize.allCases, id: \.self) { Text($0.rawValue).tag($0) }
          }
          TextField("Milk", text: $milk)
          Stepper("Sugar: \(sugar) tsp", value: $sugar, in: 0...4)
          TextField("Notes (optional)", text: $notes)
          Toggle("Save as favorite", isOn: $isFavorite)
        }

        if isFavorite {
          Section {
            Text("This order will be saved to Favorites for quick reuse.")
              .font(.footnote)
              .foregroundStyle(.secondary)
          }
        }
      }
      .navigationTitle(existingOrder == nil ? "New Order" : "Edit Order")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button(existingOrder == nil ? "Add" : "Save") {
            let newOrder = PersonOrder(
              id: existingOrder?.id ?? UUID(),
              name: name,
              drink: drink,
              size: size,
              milk: milk,
              sugar: sugar,
              notes: notes,
              isFavorite: isFavorite
            )
            if isFavorite { store.upsertFavorite(newOrder) }
            // You can also pass this back via a binding/closure if needed
            dismiss()
          }
          .disabled(!isValid)
        }
      }

      // iOS 17 onChange patterns
      .onChange(of: name) { _, _ in validate() }     // you don't need the values here
      .onChange(of: drink) { _, _ in validate() }    // two-parameter form
      .onChange(of: size) { _, _ in validate() }

      .onAppear {
        if let o = existingOrder {
          name = o.name
          drink = o.drink
          size = o.size
          milk = o.milk
          sugar = o.sugar
          notes = o.notes
          isFavorite = o.isFavorite
        }
        validate()
        // focus name on first appear for quick entry
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          focusedField = true
        }
      }
    }
  }

  private func validate() {
    isValid = !name.trimmingCharacters(in: .whitespaces).isEmpty
  }
}

#Preview {
  OrderDetailView(existingOrder: PersonOrder(
    name: "Aisha",
    drink: .latte,
    size: .large,
    milk: "Almond",
    sugar: 1,
    notes: "extra hot",
    isFavorite: true
  ))
  .environmentObject(SavedOrdersStore())
}
