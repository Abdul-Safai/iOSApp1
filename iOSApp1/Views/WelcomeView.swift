import SwiftUI

struct WelcomeView: View {
  @Binding var selectedTab: Int
  @State private var showHistory: Bool = false

  private let orderTabIndex = 0   // your Create Orders page

  var body: some View {
    VStack(spacing: 0) {

      // Pretty header (gradient + title + subtitle)
      ZStack {
        LinearGradient(
          colors: [Color.blue.opacity(0.25), Color.cyan.opacity(0.15)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea(edges: .top)

        VStack(spacing: 6) {
          Text("Coffee Run")
            .font(.system(size: 34, weight: .bold))
          Text("Tim Hortons teamwork made easy")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 22)
        .padding(.bottom, 16)
      }
      .frame(height: 140)

      Spacer()

      // Center content
      VStack(spacing: 16) {
        Image(systemName: "cup.and.saucer.fill")
          .font(.system(size: 72, weight: .bold))
          .symbolRenderingMode(.hierarchical)

        Text("Welcome")
          .font(.largeTitle).bold()

        Text("Record your team’s orders and reorder in seconds.")
          .multilineTextAlignment(.center)
          .foregroundStyle(.secondary)
          .padding(.horizontal)

        // Extra gap before buttons (per your request)
        VStack(spacing: 14) {
          Button {
            selectedTab = orderTabIndex
          } label: {
            Label("Create Orders", systemImage: "plus.circle.fill")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.borderedProminent)

          Button {
            showHistory = true
          } label: {
            Label("History", systemImage: "clock.arrow.circlepath")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
        }
        .padding(.top, 22) // 👈 pushes buttons a bit more down
        .padding(.horizontal)
      }

      Spacer()
    }
    .sheet(isPresented: $showHistory) {
      // Pass selectedTab so Reorder can jump straight to Run
      HistoryView(showHistory: $showHistory, selectedTab: $selectedTab)
    }
  }
}

#Preview {
  WelcomeView(selectedTab: .constant(9))
}
