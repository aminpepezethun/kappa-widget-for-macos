import Testing
import SwiftUI
@testable import ohwell

@Suite("ParticleSystem")
@MainActor
struct ParticleSystemTests {

    // MARK: - burst

    @Test func burstCreatesCorrectCount() {
        let ps = ParticleSystem()
        ps.burst(at: CGPoint(x: 100, y: 100),
                 symbols: ["star.fill"],
                 colors: [.red],
                 count: 10)
        #expect(ps.particles.count == 10)
    }

    @Test func burstDefaultCountIsTwenty() {
        let ps = ParticleSystem()
        ps.burst(at: .zero, symbols: ["star.fill"], colors: [.red])
        #expect(ps.particles.count == 20)
    }

    @Test func burstCyclesSymbols() {
        let ps = ParticleSystem()
        ps.burst(at: .zero, symbols: ["star.fill", "circle.fill"], colors: [.red], count: 4)
        #expect(ps.particles[0].symbol == "star.fill")
        #expect(ps.particles[1].symbol == "circle.fill")
        #expect(ps.particles[2].symbol == "star.fill")   // wraps
        #expect(ps.particles[3].symbol == "circle.fill")
    }

    @Test func burstCyclesColors() {
        let ps = ParticleSystem()
        ps.burst(at: .zero, symbols: ["star.fill"], colors: [.red, .blue], count: 4)
        // Colors cycle: red, blue, red, blue
        #expect(ps.particles.count == 4)
    }

    @Test func burstParticlesSpawnAtGivenPoint() {
        let ps = ParticleSystem()
        let origin = CGPoint(x: 160, y: 240)
        ps.burst(at: origin, symbols: ["star.fill"], colors: [.red], count: 5)
        for particle in ps.particles {
            #expect(particle.x == origin.x)
            #expect(particle.y == origin.y)
        }
    }

    @Test func burstParticlesHaveFullOpacity() {
        let ps = ParticleSystem()
        ps.burst(at: .zero, symbols: ["star.fill"], colors: [.red], count: 3)
        for particle in ps.particles {
            #expect(particle.opacity == 1.0)
            #expect(particle.lifetime == 1.0)
        }
    }

    @Test func burstParticlesHaveUniqueIds() {
        let ps = ParticleSystem()
        ps.burst(at: .zero, symbols: ["star.fill"], colors: [.red], count: 5)
        let ids = Set(ps.particles.map(\.id))
        #expect(ids.count == 5)
    }

    // MARK: - update

    @Test func updateMovesParticles() {
        let ps = ParticleSystem()
        ps.burst(at: CGPoint(x: 100, y: 100), symbols: ["star.fill"], colors: [.red], count: 1)
        let originalX = ps.particles[0].x
        let originalY = ps.particles[0].y
        ps.update(deltaTime: 0.1)
        // Particle must have moved (velocity is non-zero by construction)
        let movedX = ps.particles.first?.x ?? originalX
        let movedY = ps.particles.first?.y ?? originalY
        #expect(movedX != originalX || movedY != originalY)
    }

    @Test func updateReducesLifetime() {
        let ps = ParticleSystem()
        ps.burst(at: .zero, symbols: ["star.fill"], colors: [.red], count: 1)
        ps.update(deltaTime: 0.016)
        if let p = ps.particles.first {
            #expect(p.lifetime < 1.0)
        }
    }

    @Test func updateReducesOpacity() {
        let ps = ParticleSystem()
        ps.burst(at: .zero, symbols: ["star.fill"], colors: [.red], count: 1)
        ps.update(deltaTime: 0.016)
        if let p = ps.particles.first {
            #expect(p.opacity < 1.0)
        }
    }

    @Test func updateRemovesExpiredParticles() {
        let ps = ParticleSystem()
        ps.burst(at: .zero, symbols: ["star.fill"], colors: [.red], count: 5)
        // Run many updates to expire all particles (lifetime decays by ~0.016/frame)
        for _ in 0..<100 {
            ps.update(deltaTime: 0.016)
        }
        #expect(ps.particles.isEmpty)
    }

    @Test func updateAppliesGravity() {
        let ps = ParticleSystem()
        ps.burst(at: CGPoint(x: 0, y: 0), symbols: ["star.fill"], colors: [.red], count: 1)
        let initialVelocityY = ps.particles[0].velocityY
        ps.update(deltaTime: 0.1)
        if let p = ps.particles.first {
            // velocityY increases (gravity pulls downward = positive Y in SwiftUI)
            #expect(p.velocityY > initialVelocityY)
        }
    }

    // MARK: - multiple bursts

    @Test func multipleBurstsAccumulate() {
        let ps = ParticleSystem()
        ps.burst(at: .zero, symbols: ["star.fill"], colors: [.red], count: 5)
        ps.burst(at: .zero, symbols: ["circle.fill"], colors: [.blue], count: 5)
        #expect(ps.particles.count == 10)
    }
}
