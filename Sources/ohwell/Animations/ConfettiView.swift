import SwiftUI

struct ConfettiView: View {
    @Environment(AppState.self) private var appState
    @State private var particleSystem = ParticleSystem()
    @State private var lastTriggerCount = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                // Update physics
                particleSystem.update(deltaTime: 1.0 / 60.0)

                // Draw particles
                for particle in particleSystem.particles {
                    if let resolved = ctx.resolveSymbol(id: particle.id) {
                        var ctx = ctx
                        ctx.opacity = particle.opacity
                        ctx.draw(resolved,
                                 at: CGPoint(x: particle.x, y: particle.y),
                                 anchor: .center)
                    }
                }
            } symbols: {
                ForEach(particleSystem.particles) { particle in
                    Image(systemName: particle.symbol)
                        .font(.system(size: 14 * particle.scale))
                        .foregroundStyle(particle.color)
                        .rotationEffect(.degrees(particle.rotation))
                        .id(particle.id)
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: appState.completionTriggers.count) { _, newCount in
            guard newCount > lastTriggerCount else { return }
            lastTriggerCount = newCount
            particleSystem.burst(
                at: CGPoint(x: 160, y: 240),   // center of 320×480 popover
                symbols: appState.currentTheme.particleSymbols,
                colors: appState.currentTheme.particleColors
            )
        }
    }
}
