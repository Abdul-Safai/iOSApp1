import Foundation
import Combine

final class CurrentRunStore: ObservableObject {
  @Published var orders: [PersonOrder] = []

  func add(_ order: PersonOrder) {
    orders.append(order)
  }

  func add(contentsOf orders: [PersonOrder]) {
    self.orders.append(contentsOf: orders)
  }

  func remove(atOffsets offsets: IndexSet) {
    orders.remove(atOffsets: offsets)
  }

  // NEW:
  func remove(at index: Int) {
    orders.remove(at: index)
  }

  // NEW:
  func replace(at index: Int, with order: PersonOrder) {
    orders[index] = order
  }

  func clear() {
    orders.removeAll()
  }
}
