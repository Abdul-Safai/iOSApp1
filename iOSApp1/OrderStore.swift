import Foundation
import Combine

final class OrderStore: ObservableObject {
    @Published var people: [Person] = []
    @Published var currentRun: [UUID: Order] = [:]

    private let saveKey = "coffee_people_v1"
    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
        $people
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)
    }

    // MARK: - CRUD
    func addPerson(name: String) {
        let t = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        people.append(Person(name: t))
    }

    func deletePeople(at offsets: IndexSet) {
        people.remove(atOffsets: offsets)
    }

    func draftOrder(for person: Person) -> Order {
        if let existing = currentRun[person.id] { return existing }
        if let fav = person.favorite { return fav }
        if let last = person.lastOrder { return last }
        return Order()
    }

    func updateDraft(for person: Person, order: Order) {
        currentRun[person.id] = order
    }

    func clearDraft(for person: Person) {
        currentRun[person.id] = nil
    }

    func saveFavorite(for person: Person, order: Order) {
        guard let idx = people.firstIndex(where: { $0.id == person.id }) else { return }
        people[idx].favorite = order
    }

    func submitOrder(for person: Person) {
        guard let idx = people.firstIndex(where: { $0.id == person.id }),
              let order = currentRun[person.id] else { return }
        people[idx].lastOrder = order
        currentRun[person.id] = nil
    }

    func clearLastOrder(for person: Person) {
        guard let idx = people.firstIndex(where: { $0.id == person.id }) else { return }
        people[idx].lastOrder = nil
    }

    // MARK: - Persistence
    private func save() {
        do {
            let data = try JSONEncoder().encode(people)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Failed to save people: \(error)")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Person].self, from: data) {
            people = decoded
        } else {
            people = [Person(name: "Abdul"), Person(name: "Michael"), Person(name: "Doug")]
        }
    }
}
