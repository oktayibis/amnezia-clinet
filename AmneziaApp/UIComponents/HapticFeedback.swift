import SwiftUI
#if canImport(UIKit)
import UIKit

public final class HapticFeedback: Sendable {
    @MainActor
    public static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor
    public static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    @MainActor
    public static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
#else
public final class HapticFeedback: Sendable {
    public static func impact() {}
    public static func notification() {}
    public static func selection() {}
}
#endif
