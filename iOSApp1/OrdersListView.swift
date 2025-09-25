import SwiftUI

struct OrdersListView: View {
  @EnvironmentObject var store: SavedOrdersStore
  @State private var showHistory: Bool = true // toggle if you like

  var body: some View {
    NavigationStack {
      List {
        if !store.favorites.isEmpty {
          Section("Favorites") {
            ForEach(store.favorites) { order in
              OrderRowView(order: order)
            }
          }
        }

        if showHistory && !store.history.isEmpty {
          ForEach(store.history) { day in
            Section(day.date.formatted(as: "MMM d, yyyy")) {
              ForEach(day.orders) { order in
                OrderRowView(order: order)
              }
            }
          }
        }

        if store.favorites.isEmpty && store.history.isEmpty {
          Section {
            Text("No favorites or history yet.")
              .foregroundStyle(.secondary)
          }
        }
      }
      .navigationTitle("Orders")
    }
  }
}

/// A small, explicit row view keeps the type-checker fast.
private struct OrderRowView: View {
  let order: PersonOrder

  var subtitle: String {
    // explicit string building avoids complex ViewBuilder logic
    var parts: [String] = []
    parts.append("S\(order.sugar)")
    parts.append(order.milk)
    if !order.notes.trimmingCharacters(in: .whitespaces).isEmpty {
      parts.append(order.notes)
    }
    return parts.joined(separator: " • ")
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text("\(order.name) — \(order.size.rawValue) \(order.drink.rawValue)")
      Text(subtitle)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  // Preview with some lightweight sample data
  let sampleStore = SavedOrdersStore()
  sampleStore.favorites = [
    PersonOrder(name: "Aisha", drink: .latte, size: .large, milk: "Almond", sugar: 1, notes: "extra hot", isFavorite: true),
    PersonOrder(name: "Ben", drink: .coffee, size: .medium, milk: "2% milk", sugar: 2, notes: "")
  ]
  sampleStore.history = [
    CoffeeRunDay(id: UUID(), date: Date(), orders: sampleStore.favorites)
  ]
  return OrdersListView().environmentObject(sampleStore)
}
