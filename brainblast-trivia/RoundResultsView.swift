import SwiftUI

struct RoundResultsView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 20) {
            Text("Round \(gameState.currentRound) Results")
                .font(.title)
                .padding()
            
            if let question = gameState.currentQuestion {
                Text(question.question)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text("Correct Answer: \(question.answer)")
                    .font(.subheadline)
                    .padding()
                
                if let p1 = gameState.player1Answer {
                    VStack {
                        Text("Player 1")
                            .font(.headline)
                        Text("Answer: \(p1.answer)")
                        Text(String(format: "Time: %.3f seconds", p1.time))
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                
                if let p2 = gameState.player2Answer {
                    VStack {
                        Text("Player 2")
                            .font(.headline)
                        Text("Answer: \(p2.answer)")
                        Text(String(format: "Time: %.3f seconds", p2.time))
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            
            if let winner = gameState.roundWinner {
                Text("Round Winner: Player \(winner)")
                    .font(.title2)
                    .padding()
            }
            
            Button("Continue") {
                withAnimation {
                    gameState.showRoundResults = false
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
