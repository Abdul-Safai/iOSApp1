import Foundation

enum DrinkType: String, CaseIterable, Codable, Identifiable {
    case coffee = "Coffee"
    case tea = "Tea"
    case latte = "Latte"
    case icedCoffee = "Iced Coffee"
    case frenchVanilla = "French Vanilla"
    case hotChocolate = "Hot Chocolate"
    case espresso = "Espresso"
    var id: String { rawValue }
}

enum CupSize: String, CaseIterable, Codable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"
    var id: String { rawValue }
}

struct Order: Identifiable, Codable, Equatable {
    var id = UUID()
    var drink: DrinkType = .coffee
    var size: CupSize = .medium
    var sugars: Int = 0
    var milks: Int = 0
    var decaf: Bool = false
    var iced: Bool = false
    var notes: String = ""
}

struct Person: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var favorite: Order? = nil
    var lastOrder: Order? = nil
}
