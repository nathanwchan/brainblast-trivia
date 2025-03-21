import SwiftUI

struct RoundResultsView: View {
    @ObservedObject var gameState: GameState
    @EnvironmentObject private var cloudKit: CloudKitManager
    @State private var player1Name = ""
    @State private var player2Name = ""
    private let displayRound: Int
    
    init(gameState: GameState) {
        self.gameState = gameState
        self.displayRound = gameState.currentRound
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Round \(displayRound) Results")
                .font(.title)
                .padding()
            
            if let question = gameState.currentQuestion,
               let match = gameState.currentMatch {
                Text(question.question)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Correct Answer: \(question.answer)")
                    .font(.title3)
                    .foregroundColor(.green)
                    .padding()
                
                // Player 1 Answer Section
                VStack {
                    Text(gameState.isPlayer1 ? "You" : player1Name)
                        .font(.headline)
                    
                    if let p1Answer = match.player1Answer,
                       let p1Time = match.player1Time {
                        Text("Answer: \(p1Answer)")
                            .foregroundColor(p1Answer == question.answer && gameState.roundWinner == 1 ? .green : .red)
                        Text(String(format: "Time: %.2f seconds", p1Time))
                    } else {
                        Text("Waiting for answer...")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.rainbowGradient.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(gameState.roundWinner == 1 ? Color.green : Color.clear, lineWidth: 3)
                        )
                )
                
                // Player 2 Answer Section
                VStack {
                    Text(!gameState.isPlayer1 ? "You" : player2Name)
                        .font(.headline)
                    
                    if let p2Answer = match.player2Answer,
                       let p2Time = match.player2Time {
                        Text("Answer: \(p2Answer)")
                            .foregroundColor(p2Answer == question.answer && gameState.roundWinner == 2 ? .green : .red)
                        Text(String(format: "Time: %.2f seconds", p2Time))
                    } else {
                        Text("Waiting for answer...")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.rainbowGradient.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(gameState.roundWinner == 2 ? Color.green : Color.clear, lineWidth: 3)
                        )
                )
                
                if let p1Answer = match.player1Answer,
                   let p2Answer = match.player2Answer,
                   p1Answer != question.answer && p2Answer != question.answer {
                    Text("Round tied - both answers were incorrect")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .padding()
                } else if let winner = gameState.roundWinner {
                    Text(
                        (gameState.isPlayer1 && winner == 1) || (!gameState.isPlayer1 && winner == 2)
                        ? "You won this round!"
                        : "\(winner == 1 ? player1Name : player2Name) won this round!"
                    )
                        .font(.title2)
                        .foregroundColor(.green)
                        .padding()
                }
                
                Button("Continue") {
                    Task {
                        try? await gameState.completeRound()
                        withAnimation {
                            gameState.showRoundResults = false
                        }
                    }
                }
                .padding()
                .background(Color.rainbowGradient)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.black.opacity(0.85))
        .cornerRadius(20)
        .shadow(radius: 10)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            // Load player names
            if let match = gameState.currentMatch {
                player1Name = await CloudKitManager.shared.getUserName(for: match.player1ID) ?? "Player 1"
                if let player2ID = match.player2ID {
                    player2Name = await CloudKitManager.shared.getUserName(for: player2ID) ?? "Player 2"
                } else {
                    player2Name = "Player 2"
                }
            }
        }
    }
}
