import SwiftUI

struct WelcomeView: View {
  @Binding var selectedTab: Int                 // <-- needed to pass down
  @State private var showHistory: Bool = false

  // If you use environment stores, they’ll flow down automatically from ContentView.
  // @EnvironmentObject var store: SavedOrdersStore
  // @EnvironmentObject var currentRun: CurrentRunStore

  var body: some View {
    VStack(spacing: 16) {
      // Your header (use whatever HeaderView you already have)
      // HeaderView(title: "Welcome", stepCount: 0, selectedStep: nil)
      Text("Welcome").font(.largeTitle).padding(.top)

      Spacer()

      Button {
        selectedTab = 0  // jump to Create Orders screen
      } label: {
        Label("Create Orders", systemImage: "cup.and.saucer.fill")
      }
      .buttonStyle(.borderedProminent)

      Button {
        showHistory = true
      } label: {
        Label("History", systemImage: "clock.arrow.circlepath")
      }
      .padding(.bottom)
    }
    .sheet(isPresented: $showHistory) {
      // ✅ FIX: pass selectedTab as well
      HistoryView(showHistory: $showHistory, selectedTab: $selectedTab)
      // If your HistoryView relies on environment objects, don’t re-inject here;
      // they’re already available from the parent (ContentView).
      // .environmentObject(store)
      // .environmentObject(currentRun)
    }
    .padding(.horizontal)
  }
}

#Preview {
  WelcomeView(selectedTab: .constant(9))
}
