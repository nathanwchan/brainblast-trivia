import SwiftUI

struct RoundResultsView: View {
    @ObservedObject var gameState: GameState
    @EnvironmentObject private var cloudKit: CloudKitManager
    @State private var player1Name = ""
    @State private var player2Name = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Round \(gameState.currentRound) Results")
                .font(.title)
                .padding()
            
            if let question = gameState.currentQuestion {
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
                    
                    if let p1 = gameState.player1Answer {
                        Text("Answer: \(p1.answer)")
                            .foregroundColor(p1.answer == question.answer ? .green : .red)
                        Text(String(format: "Time: %.2f seconds", p1.time))
                    } else {
                        Text("Waiting for answer...")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(gameState.roundWinner == 1 ? Color.green : Color.clear, lineWidth: 3)
                        )
                )
                
                // Player 2 Answer Section
                VStack {
                    Text(!gameState.isPlayer1 ? "You" : player2Name)
                        .font(.headline)
                    
                    if let p2 = gameState.player2Answer {
                        Text("Answer: \(p2.answer)")
                            .foregroundColor(p2.answer == question.answer ? .green : .red)
                        Text(String(format: "Time: %.2f seconds", p2.time))
                    } else {
                        Text("Waiting for answer...")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(gameState.roundWinner == 2 ? Color.green : Color.clear, lineWidth: 3)
                        )
                )
            }
            
            if let winner = gameState.roundWinner {
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
