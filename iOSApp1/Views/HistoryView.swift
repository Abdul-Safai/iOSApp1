import SwiftUI

struct HistoryView: View {
  @Binding var showHistory: Bool
  @Binding var selectedTab: Int
  @EnvironmentObject var store: SavedOrdersStore
  @EnvironmentObject var currentRun: CurrentRunStore  // 👈 same cart

  private let orderTabIndex = 0

  var body: some View {
    NavigationStack {
      List {
        ForEach(store.history) { day in
          Section(day.date.formatted(as: "MMM d, yyyy")) {

            if !day.orders.isEmpty {
              Button {
                currentRun.add(contentsOf: day.orders)   // 👈 put ALL into cart
                selectedTab = orderTabIndex               // go to Create Orders
                showHistory = false                       // close sheet
              } label: {
                Label("Reorder All From This Day", systemImage: "arrow.uturn.down")
              }
            }

            ForEach(day.orders) { o in
              HStack {
                VStack(alignment: .leading, spacing: 2) {
                  Text("\(o.name) — \(o.size.rawValue) \(o.drink.rawValue)")
                  Text("S\(o.sugar) • \(o.milk) \(o.notes.isEmpty ? "" : "• \(o.notes)")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Reorder") {
                  currentRun.add(o)                       // 👈 put ONE into cart
                  selectedTab = orderTabIndex
                  showHistory = false
                }
                .buttonStyle(.bordered)
              }
            }
          }
        }

        if store.history.isEmpty {
          Section {
            Text("No history yet. Place an order to see it here.")
              .foregroundStyle(.secondary)
          }
        }
      }
      .navigationTitle("Coffee Run History")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button { showHistory = false } label: { Image(systemName: "xmark.circle") }
        }
      }
    }
  }
}
