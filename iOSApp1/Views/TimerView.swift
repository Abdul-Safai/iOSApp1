import SwiftUI

private struct TickView: View {
  let date: Date
  @Binding var remaining: Int
  let size: Double

  var body: some View {
    Text("\(remaining)")
      .font(.system(size: size, design: .rounded))
      .monospacedDigit()
      .padding(.vertical, 8)
      // iOS 17+: two-parameter closure
      .onChange(of: date) { _, _ in
        remaining = max(remaining - 1, 0)
      }
  }
}

/// Countdown timer that sets `done = true` when it hits 0.
struct TimerView: View {
  @Binding var done: Bool
  @State private var remaining: Int = 30   // set to 5 for demo if you like
  let size: Double

  var body: some View {
    TimelineView(.animation(minimumInterval: 1, paused: remaining <= 0)) { ctx in
      TickView(date: ctx.date, remaining: $remaining, size: size)
    }
    // iOS 17+: two-parameter closure
    .onChange(of: remaining) { _, newValue in
      if newValue == 0 { done = true }
    }
  }
}

#Preview {
  TimerView(done: .constant(false), size: 64)
}
