import Foundation

extension Date {
  func formatted(as format: String) -> String {
    let df = DateFormatter()
    df.dateFormat = format
    return df.string(from: self)
  }
}
