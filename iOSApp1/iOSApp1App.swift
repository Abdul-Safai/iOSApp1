import SwiftUI

@main
struct iOSApp1App: App {
    @StateObject private var store = OrderStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
