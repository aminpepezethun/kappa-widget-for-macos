import SwiftUI

struct IconBouncerModifier: ViewModifier {
    let style: IconAnimationStyle
    let isActive: Bool

    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .modifier(animation(for: style))
            .onAppear {
                guard isActive else { return }
                withAnimation(repeatAnimation) {
                    animating = true
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(repeatAnimation) {
                        animating = true
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        animating = false
                    }
                }
            }
    }

    // MARK: - Per-style modifier

    private func animation(for style: IconAnimationStyle) -> some ViewModifier {
        switch style {
        case .bounce:
            return AnyIconAnimation(offset: CGSize(width: 0, height: animating ? -4 : 0),
                                    scale: 1.0,
                                    rotation: 0,
                                    orbitOffset: .zero)
        case .pulse:
            return AnyIconAnimation(offset: .zero,
                                    scale: animating ? 1.2 : 1.0,
                                    rotation: 0,
                                    orbitOffset: .zero)
        case .wiggle:
            return AnyIconAnimation(offset: .zero,
                                    scale: 1.0,
                                    rotation: animating ? 15 : 0,
                                    orbitOffset: .zero)
        case .orbit(let radius):
            return AnyIconAnimation(offset: .zero,
                                    scale: 1.0,
                                    rotation: 0,
                                    orbitOffset: CGSize(
                                        width: animating ? radius : 0,
                                        height: animating ? radius : 0
                                    ))
        }
    }

    private var repeatAnimation: Animation {
        switch style {
        case .bounce:
            return .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
        case .pulse:
            return .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        case .wiggle:
            return .easeInOut(duration: 0.3).repeatForever(autoreverses: true)
        case .orbit:
            return .linear(duration: 1.5).repeatForever(autoreverses: false)
        }
    }
}

// MARK: - Concrete ViewModifier that applies all transforms

private struct AnyIconAnimation: ViewModifier {
    let offset: CGSize
    let scale: CGFloat
    let rotation: Double
    let orbitOffset: CGSize

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(offset)
            .offset(orbitOffset)
    }
}

// MARK: - View extension for ergonomic use

extension View {
    func iconBouncer(style: IconAnimationStyle, isActive: Bool) -> some View {
        modifier(IconBouncerModifier(style: style, isActive: isActive))
    }
}
