import SwiftUI

struct WideProminentButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
    }
}

extension View {
    func wideProminent() -> some View { modifier(WideProminentButton()) }
}
