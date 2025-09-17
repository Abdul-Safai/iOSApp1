import SwiftUI

struct OrdersListView: View {
    @EnvironmentObject private var store: OrderStore
    @State private var newName: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Add Person") {
                    HStack {
                        TextField("Name (e.g., Yasir)", text: $newName)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done)
                            .onSubmit(addPerson)

                        Button("Add", action: addPerson)
                            .buttonStyle(.plain)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .foregroundColor(.accentColor)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                if store.people.isEmpty {
                    if #available(iOS 17.0, *) {
                        Section {
                            ContentUnavailableView(
                                "No team members yet",
                                systemImage: "person.2",
                                description: Text("Add names above to start a coffee run.")
                            )
                        }
                    } else {
                        Section {
                            VStack(spacing: 8) {
                                Image(systemName: "person.2").font(.largeTitle)
                                Text("No team members yet").font(.headline)
                                Text("Add names above to start a coffee run.")
                                    .font(.footnote).foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 16)
                        }
                    }
                }

                Section("Team") {
                    ForEach(store.people) { person in
                        NavigationLink {
                            OrderDetailView(person: person)
                        } label: {
                            HStack {
                                Text(person.name)
                                Spacer()
                                if let last = person.lastOrder {
                                    Text(summary(of: last))
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                } else {
                                    Text("No orders yet")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .onDelete(perform: store.deletePeople)
                }
            }
            .navigationTitle("Tim Hortons Run")
            .listStyle(.insetGrouped)
            .scrollContentBackground(.automatic)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    if !store.people.isEmpty {
                        ShareLink(item: summaryForSharing()) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share today's orders")
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func addPerson() {
        store.addPerson(name: newName)
        newName = ""
    }
    private func summary(of order: Order) -> String {
        var parts = [order.size.rawValue, order.drink.rawValue]
        if order.decaf { parts.append("Decaf") }
        if order.iced { parts.append("Iced") }
        if order.sugars > 0 { parts.append("\(order.sugars)x sugar") }
        if order.milks > 0 { parts.append("\(order.milks)x milk") }
        if !order.notes.isEmpty { parts.append("[\(order.notes)]") }
        return parts.joined(separator: " • ")
    }
    private func summaryForSharing() -> String {
        var lines: [String] = ["Tim Hortons Run"]
        for p in store.people {
            if let o = p.lastOrder {
                let row = [
                    p.name + ":", o.size.rawValue, o.drink.rawValue,
                    o.decaf ? "(Decaf)" : "", o.iced ? "(Iced)" : "",
                    o.sugars > 0 ? "\(o.sugars)x sugar" : "",
                    o.milks > 0 ? "\(o.milks)x milk" : "",
                    o.notes.isEmpty ? "" : "[\(o.notes)]"
                ].filter { !$0.isEmpty }.joined(separator: " ")
                lines.append(row)
            }
        }
        return lines.joined(separator: "\n")
    }
}

#Preview {
    OrdersListView().environmentObject(OrderStore())
}
