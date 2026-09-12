import SwiftUI

public struct MacGlassCard<Content: View>: View {
    private let content: Content
    private let cornerRadius: CGFloat
    private let strokeColor: Color

    public init(
        cornerRadius: CGFloat = 14,
        strokeColor: Color = Color.white.opacity(0.1),
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.strokeColor = strokeColor
        self.content = content()
    }

    public var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
    }
}
