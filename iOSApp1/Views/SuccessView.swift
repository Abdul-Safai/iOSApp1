import SwiftUI

struct SuccessView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var selectedTab: Int

  var body: some View {
    ZStack {
      VStack(spacing: 14) {
        Spacer()
        Image(systemName: "hands.clap.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 72, height: 72)
          .foregroundStyle(.green)
        Text("Order Placed!")
          .font(.largeTitle).bold()
        Text("Nice work. Your team’s Timmies are on their way 🍩☕️")
          .multilineTextAlignment(.center)
          .foregroundStyle(.secondary)
          .padding(.horizontal)
        Spacer()
      }
      VStack {
        Spacer()
        Button("Continue") {
          selectedTab = 9  // back to Welcome
          dismiss()
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom)
      }
    }
    .padding(.horizontal)
  }
}

#Preview { SuccessView(selectedTab: .constant(9)) }
