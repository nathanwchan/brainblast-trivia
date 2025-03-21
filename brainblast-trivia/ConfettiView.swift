import SwiftUI

struct RainbowParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var rotation: Double
    var color: Color
}

struct ConfettiView: View {
    @State private var particles: [RainbowParticle] = []
    @State private var timer: Timer?
    let colors: [Color] = [
        .red,         // Vibrant red
        .orange,      // Bright orange
        .yellow,      // Sunny yellow
        .green,       // Spring green
        .blue,        // Sky blue
        .purple       // Electric purple
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    EmitterView(color: particle.color)
                        .position(x: particle.x, y: particle.y)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .onAppear {
                startCelebration(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func startCelebration(in size: CGSize) {
        for _ in 0...150 {
            particles.append(createParticle(in: size))
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            withAnimation(.linear(duration: 0.016)) {
                for i in particles.indices {
                    particles[i].y += CGFloat.random(in: 3...7)
                    
                    particles[i].x += CGFloat.random(in: -2...2)
                    
                    particles[i].rotation += Double.random(in: -5...5)
                    
                    if particles[i].y > size.height + 50 {
                        particles[i] = createParticle(in: size)
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            timer?.invalidate()
            withAnimation(.easeOut(duration: 0.5)) {
                particles.removeAll()
            }
        }
    }
    
    private func createParticle(in size: CGSize) -> RainbowParticle {
        RainbowParticle(
            x: CGFloat.random(in: 0...size.width),
            y: -20,
            scale: CGFloat.random(in: 0.5...1.2),
            rotation: Double.random(in: 0...360),
            color: colors.randomElement() ?? .red
        )
    }
}

struct EmitterView: View {
    let color: Color
    
    var body: some View {
        Group {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .blur(radius: 0.5)
            
            Image(systemName: "star.fill")
                .foregroundColor(color)
                .font(.system(size: 16))
            
            Rectangle()
                .fill(color)
                .frame(width: 10, height: 3)
                .cornerRadius(1)
        }
    }
}
