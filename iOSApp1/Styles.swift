import SwiftUI

/// Filled, wide button (no reliance on .borderedProminent)
struct WideProminentButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
/// Outlined, wide button (no reliance on .bordered)
struct WideBorderedButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(Color.accentColor)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
    }
}
extension View {
    func wideProminent() -> some View { modifier(WideProminentButton()) }
    func wideBordered() -> some View { modifier(WideBorderedButton()) }
}
