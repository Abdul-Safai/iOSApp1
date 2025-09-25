import Foundation
import Combine

private enum StoreKeys {
  static let favorites = "favorites.v1"
  static let history = "history.v1"
}

final class SavedOrdersStore: ObservableObject {
  @Published var favorites: [PersonOrder] = []     // quick re-use
  @Published var history: [CoffeeRunDay] = []      // newest first

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  init() {
    load()
  }

  // MARK: - Favorites
  func upsertFavorite(_ order: PersonOrder) {
    if let idx = favorites.firstIndex(where: { $0.id == order.id }) {
      favorites[idx] = order
    } else {
      var fav = order; fav.isFavorite = true
      favorites.append(fav)
    }
    persist()
  }

  func removeFavorite(id: UUID) {
    favorites.removeAll { $0.id == id }
    persist()
  }

  // MARK: - History
  func addToToday(_ orders: [PersonOrder]) {
    let today = Date()
    if let first = history.first, Calendar.current.isDate(first.date, inSameDayAs: today) {
      history[0].orders.append(contentsOf: orders)
    } else {
      history.insert(CoffeeRunDay(id: UUID(), date: today, orders: orders), at: 0)
    }
    persist()
  }

  // MARK: - Persistence
  private func persist() {
    if let favData = try? encoder.encode(favorites) {
      UserDefaults.standard.set(favData, forKey: StoreKeys.favorites)
    }
    if let histData = try? encoder.encode(history) {
      UserDefaults.standard.set(histData, forKey: StoreKeys.history)
    }
  }

  private func load() {
    if let favData = UserDefaults.standard.data(forKey: StoreKeys.favorites),
       let favs = try? decoder.decode([PersonOrder].self, from: favData) {
      favorites = favs
    }
    if let histData = UserDefaults.standard.data(forKey: StoreKeys.history),
       let days = try? decoder.decode([CoffeeRunDay].self, from: histData) {
      history = days
    }
  }
}
