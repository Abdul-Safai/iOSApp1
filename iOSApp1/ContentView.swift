import SwiftUI

struct ContentView: View {
  @State private var selectedTab: Int = 9  // 9 = Welcome, 0 = Create Orders
  @StateObject private var savedStore = SavedOrdersStore()
  @StateObject private var currentRun = CurrentRunStore()  // 👈 shared cart

  var body: some View {
    TabView(selection: $selectedTab) {
      WelcomeView(selectedTab: $selectedTab)
        .tag(9)

      OrderView(selectedTab: $selectedTab)
        .tag(0)
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .environmentObject(savedStore)
    .environmentObject(currentRun)            // 👈 inject
  }
}

#Preview { ContentView() }
