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
                            .buttonStyle(.borderedProminent)
                            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
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
            .toolbar { EditButton() }
        }
    }

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
        return parts.joined(separator: " • ")
    }
}

#Preview {
    OrdersListView().environmentObject(OrderStore())
}
