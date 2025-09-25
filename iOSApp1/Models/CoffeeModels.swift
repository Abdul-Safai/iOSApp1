import Foundation

// Namespaced to avoid clashes with any tutorial/demo types.
enum THDrink: String, CaseIterable, Codable {
  case coffee = "Coffee"
  case latte = "Latte"
  case cappuccino = "Cappuccino"
  case tea = "Tea"
  case icedCoffee = "Iced Coffee"
}

enum THCupSize: String, CaseIterable, Codable {
  case small = "Small"
  case medium = "Medium"
  case large = "Large"
}

struct PersonOrder: Identifiable, Codable, Equatable {
  let id: UUID
  var name: String
  var drink: THDrink
  var size: THCupSize
  var milk: String
  var sugar: Int
  var notes: String
  var isFavorite: Bool

  init(
    id: UUID = UUID(),
    name: String,
    drink: THDrink,
    size: THCupSize,
    milk: String,
    sugar: Int,
    notes: String = "",
    isFavorite: Bool = false
  ) {
    self.id = id
    self.name = name
    self.drink = drink
    self.size = size
    self.milk = milk
    self.sugar = sugar
    self.notes = notes
    self.isFavorite = isFavorite
  }
}

struct CoffeeRunDay: Identifiable, Codable, Equatable {
  let id: UUID
  let date: Date
  var orders: [PersonOrder]
}
