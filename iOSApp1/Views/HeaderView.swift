import SwiftUI

/// Simple header with title + optional page dots (for future multi-step order flow)
struct HeaderView: View {
  let title: String
  let stepCount: Int
  let selectedStep: Int?

  var body: some View {
    VStack(spacing: 8) {
      Text(title).font(.largeTitle).bold()
      if stepCount > 0 {
        HStack {
          ForEach(0..<stepCount, id: \.self) { i in
            Image(systemName: i == selectedStep ? "circle.inset.filled" : "circle")
          }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
      }
    }
    .padding(.top)
  }
}

#Preview { HeaderView(title: "Tim Coffee Run", stepCount: 4, selectedStep: 0) }
