import SwiftUI

struct OrderView: View {
  @Binding var selectedTab: Int
  @EnvironmentObject var store: SavedOrdersStore
  @EnvironmentObject var currentRun: CurrentRunStore   // shared cart

  private let homeTabIndex = 9

  // --- New order being composed (unchanged core) ---
  @State private var name: String = ""

  @State private var drink: THDrink? = nil
  @State private var size: THCupSize? = nil

  private let milkOptions = ["No milk", "Cream", "Whole milk", "2% milk", "Skim", "Almond", "Oat", "Soy"]
  @State private var milk: String? = nil

  @State private var sugar: Int = 1
  @State private var notes: String = ""
  @State private var markFavorite: Bool = false

  @State private var showTimer: Bool = false
  @State private var canPlace: Bool = false

  // --- Editing state for CURRENT RUN rows ---
  @State private var showEditor: Bool = false
  @State private var editIndex: Int? = nil
  @State private var draftOrder: PersonOrder? = nil

  private func applyFavorite(_ fav: PersonOrder) {
    name = fav.name
    drink = fav.drink
    size  = fav.size
    milk  = fav.milk
    sugar = fav.sugar
    notes = fav.notes
    markFavorite = fav.isFavorite
  }

  private var canAddThisOrder: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty &&
    drink != nil && size != nil && milk != nil
  }

  // Start editing an item in the run
  private func startEditing(index i: Int) {
    guard currentRun.orders.indices.contains(i) else { return }
    editIndex = i
    draftOrder = currentRun.orders[i]
    showEditor = true
  }

  private var orderForm: some View {
    Form {
      Section("Team Member") {
        TextField("Name (e.g. Aisha)", text: $name)
      }

      Section("Drink") {
        Picker("Type", selection: $drink) {
          Text("Select Type").foregroundStyle(.secondary).tag(nil as THDrink?)
          ForEach(THDrink.allCases, id: \.self) { t in Text(t.rawValue).tag(Optional(t)) }
        }

        Picker("Size", selection: $size) {
          Text("Select Size").foregroundStyle(.secondary).tag(nil as THCupSize?)
          ForEach(THCupSize.allCases, id: \.self) { s in Text(s.rawValue).tag(Optional(s)) }
        }

        Picker("Milk Type", selection: $milk) {
          Text("Select Milk").foregroundStyle(.secondary).tag(nil as String?)
          ForEach(milkOptions, id: \.self) { m in Text(m).tag(Optional(m)) }
        }

        Stepper("Sugar: \(sugar) tsp", value: $sugar, in: 0...4)
        TextField("Notes (optional)", text: $notes)
        Toggle("Save as favorite", isOn: $markFavorite)
      }

      if !store.favorites.isEmpty {
        Section("Favorites") {
          ForEach(store.favorites) { fav in
            Button { applyFavorite(fav) } label: {
              HStack {
                Text("\(fav.name): \(fav.size.rawValue) \(fav.drink.rawValue)")
                Spacer()
                Text("S\(fav.sugar) \(fav.milk)").foregroundStyle(.secondary)
              }
            }
          }
        }
      }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      // Back to main
      HStack {
        Button {
          selectedTab = homeTabIndex
        } label: {
          HStack(spacing: 4) { Image(systemName: "chevron.left"); Text("Back") }
        }.buttonStyle(.plain)
        Spacer()
      }
      .padding(.horizontal)
      .padding(.top, 8)

      HeaderView(title: "Create Orders", stepCount: 0, selectedStep: nil)

      orderForm

      HStack(spacing: 16) {
        Button {
          guard canAddThisOrder,
                let chosenDrink = drink,
                let chosenSize  = size,
                let chosenMilk  = milk else { return }

          let order = PersonOrder(
            name: name,
            drink: chosenDrink,
            size: chosenSize,
            milk: chosenMilk,
            sugar: sugar,
            notes: notes,
            isFavorite: markFavorite
          )
          currentRun.add(order)
          if markFavorite { store.upsertFavorite(order) }
          name = ""; notes = ""; sugar = 1
        } label: {
          Label("Add To Run", systemImage: "plus.circle.fill")
        }
        .buttonStyle(.borderedProminent)

        Button {
          showTimer.toggle()
        } label: {
          Label(showTimer ? "Hide Timer" : "Start Timer", systemImage: "timer")
        }
      }
      .padding(.horizontal)

      if showTimer {
        TimerView(done: $canPlace, size: 56)
          .padding(.top, 8)
      }

      // --- CURRENT RUN with Edit/Remove ---
      List {
        Section("Current Run") {
          if currentRun.orders.isEmpty {
            Text("No orders yet. Add a teammate above.")
              .foregroundStyle(.secondary)
          } else {
            ForEach(currentRun.orders.indices, id: \.self) { i in
              let o = currentRun.orders[i]
              HStack {
                VStack(alignment: .leading, spacing: 2) {
                  Text("\(o.name) — \(o.size.rawValue) \(o.drink.rawValue)")
                  Text("S\(o.sugar) • \(o.milk) \(o.notes.isEmpty ? "" : "• \(o.notes)")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer()

                // Ellipsis menu with Edit / Remove
                Menu {
                  Button("Edit") { startEditing(index: i) }
                  Button("Remove", role: .destructive) {
                    currentRun.remove(at: i)
                  }
                } label: {
                  Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
                }
              }
              // Swipe actions too
              .swipeActions(edge: .trailing) {
                Button("Edit") { startEditing(index: i) }.tint(.blue)
                Button("Delete", role: .destructive) {
                  currentRun.remove(at: i)
                }
              }
            }
            // Keep support for List’s built-in delete gesture (optional)
            .onDelete { idx in currentRun.remove(atOffsets: idx) }
          }
        }
      }
      .listStyle(.insetGrouped)
      .frame(maxHeight: 220)

      Button {
        guard canPlace, !currentRun.orders.isEmpty else { return }
        store.addToToday(currentRun.orders)
        currentRun.clear()
        canPlace = false
        showTimer = false
        selectedTab = 99
      } label: {
        Label("Place Order", systemImage: "checkmark.seal.fill")
      }
      .buttonStyle(.borderedProminent)
      .disabled(!(canPlace && !currentRun.orders.isEmpty))
      .padding(.vertical)
    }
    .onChange(of: showTimer) { _, newValue in
      if newValue == false { canPlace = false }
    }
    .sheet(
      isPresented: $showEditor,
      onDismiss: { draftOrder = nil; editIndex = nil }
    ) {
      if let draft = draftOrder, let i = editIndex {
        OrderEditSheet(
          draft: draft,
          milkOptions: milkOptions,
          onCancel: { showEditor = false },
          onSave: { updated in
            currentRun.replace(at: i, with: updated)
            showEditor = false
          }
        )
      }
    }
    .sheet(
      isPresented: Binding(
        get: { selectedTab == 99 },
        set: { if !$0 { selectedTab = 0 } }
      )
    ) {
      SuccessView(selectedTab: $selectedTab)
        .presentationDetents([.medium, .large])
    }
  }
}

// MARK: - Edit Sheet
private struct OrderEditSheet: View {
  let milkOptions: [String]
  let onCancel: () -> Void
  let onSave: (PersonOrder) -> Void

  // Editable fields
  @State private var name: String
  @State private var drink: THDrink
  @State private var size: THCupSize
  @State private var milk: String
  @State private var sugar: Int
  @State private var notes: String
  @State private var isFavorite: Bool

  init(draft: PersonOrder,
       milkOptions: [String],
       onCancel: @escaping () -> Void,
       onSave: @escaping (PersonOrder) -> Void) {
    _name = State(initialValue: draft.name)
    _drink = State(initialValue: draft.drink)
    _size = State(initialValue: draft.size)
    _milk = State(initialValue: draft.milk)
    _sugar = State(initialValue: draft.sugar)
    _notes = State(initialValue: draft.notes)
    _isFavorite = State(initialValue: draft.isFavorite)
    self.milkOptions = milkOptions
    self.onCancel = onCancel
    self.onSave = onSave
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Team Member") {
          TextField("Name", text: $name)
        }
        Section("Drink") {
          Picker("Type", selection: $drink) {
            ForEach(THDrink.allCases, id: \.self) { Text($0.rawValue).tag($0) }
          }
          Picker("Size", selection: $size) {
            ForEach(THCupSize.allCases, id: \.self) { Text($0.rawValue).tag($0) }
          }
          Picker("Milk Type", selection: $milk) {
            ForEach(milkOptions, id: \.self) { Text($0).tag($0) }
          }
          Stepper("Sugar: \(sugar) tsp", value: $sugar, in: 0...4)
          TextField("Notes (optional)", text: $notes)
          Toggle("Save as favorite", isOn: $isFavorite)
        }
      }
      .navigationTitle("Edit Order")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: onCancel)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            onSave(PersonOrder(
              name: name,
              drink: drink,
              size: size,
              milk: milk,
              sugar: sugar,
              notes: notes,
              isFavorite: isFavorite
            ))
          }
        }
      }
    }
  }
}

#Preview {
  let saved = SavedOrdersStore()
  let run = CurrentRunStore()
  run.orders = [
    PersonOrder(name: "Aisha", drink: .latte, size: .large, milk: "Almond", sugar: 1, notes: "extra hot", isFavorite: true),
    PersonOrder(name: "Ben", drink: .coffee, size: .medium, milk: "2% milk", sugar: 2, notes: "")
  ]
  return OrderView(selectedTab: .constant(0))
    .environmentObject(saved)
    .environmentObject(run)
}
