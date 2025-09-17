import SwiftUI

@main
struct iOSApp1App: App {
    @StateObject private var store = OrderStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                // Tip: after you add a Color asset named "BrandRed", switch to .tint(Color("BrandRed"))
                .tint(.red)
        }
    }
}
