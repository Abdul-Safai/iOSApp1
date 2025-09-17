import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            OrdersListView()
                .tabItem { Label("Orders", systemImage: "list.bullet") }

            RunTimerView()
                .tabItem { Label("Run Timer", systemImage: "timer") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(OrderStore())
}
