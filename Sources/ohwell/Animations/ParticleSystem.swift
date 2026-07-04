import SwiftUI

struct Particle: Identifiable, Sendable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var opacity: CGFloat
    var scale: CGFloat
    var rotation: Double
    var rotationVelocity: Double
    var symbol: String
    var color: Color
    var lifetime: CGFloat      // 0→1 (1 = just spawned, 0 = dead)

    init(x: CGFloat, y: CGFloat, symbol: String, color: Color) {
        self.id = UUID()
        self.x = x
        self.y = y
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let speed = CGFloat.random(in: 80...200)
        self.velocityX = cos(angle) * speed
        self.velocityY = sin(angle) * speed - 150   // upward bias
        self.opacity = 1.0
        self.scale = CGFloat.random(in: 0.5...1.2)
        self.rotation = Double.random(in: 0...360)
        self.rotationVelocity = Double.random(in: -180...180)
        self.symbol = symbol
        self.color = color
        self.lifetime = 1.0
    }
}

@Observable @MainActor
final class ParticleSystem {
    var particles: [Particle] = []

    private let decayRate: CGFloat = 0.016   // per frame at 60fps ≈ 1s lifetime
    private let gravity: CGFloat = 300       // pts/s²

    func burst(at point: CGPoint, symbols: [String], colors: [Color], count: Int = 20) {
        let newParticles = (0..<count).map { i in
            Particle(
                x: point.x,
                y: point.y,
                symbol: symbols[i % symbols.count],
                color: colors[i % colors.count]
            )
        }
        particles.append(contentsOf: newParticles)
    }

    func update(deltaTime: CGFloat) {
        particles = particles.compactMap { p in
            var p = p
            p.lifetime -= decayRate
            guard p.lifetime > 0 else { return nil }

            // Physics
            p.x += p.velocityX * deltaTime
            p.y += p.velocityY * deltaTime
            p.velocityY += gravity * deltaTime   // gravity pulls down
            p.rotation += p.rotationVelocity * Double(deltaTime)
            p.opacity = p.lifetime
            return p
        }
    }
}
