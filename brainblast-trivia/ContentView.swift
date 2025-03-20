import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var isPlayer1Turn = true
    @State private var startTime: Date?
    @State private var showingAnswer = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: AnyCancellable?

    var formattedTime: String {
        let totalSeconds = Int(elapsedTime)
        let thousandths = Int((elapsedTime * 1000).truncatingRemainder(dividingBy: 1000))
        return String(format: "%02d:%03d", totalSeconds, thousandths)
    }

    var body: some View {
        VStack {
            HStack {
                Text("Player 1: \(gameState.player1Score)")
                Spacer()
                Text("Round \(gameState.currentRound)")
                Spacer()
                Text("Player 2: \(gameState.player2Score)")
            }
            .padding()
            
            if let question = gameState.currentQuestion {
                Spacer()
                
                Text(formattedTime)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
                    .padding(.bottom, 20)
                
                Text(question.question)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack(spacing: 15) {
                    ForEach(question.options, id: \.self) { option in
                        Button(action: {
                            submitAnswer(option)
                        }) {
                            Text(option)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Text(isPlayer1Turn ? "Player 1's Turn" : "Player 2's Turn")
                    .font(.headline)
                    .padding()
            } else {
                Spacer()
                Text("Loading question...")
                    .font(.title2)
                Button("Start New Game") {
                    resetGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                Spacer()
            }
        }
        .onAppear {
            startTime = Date()
            startTimer()
        }
        .alert("Game Over!", isPresented: $gameState.isGameOver) {
            Button("New Game") {
                resetGame()
            }
        } message: {
            if let winner = gameState.winner {
                Text("Player \(winner) wins!")
            }
        }
    }
    
    private func submitAnswer(_ answer: String) {
        guard let start = startTime else { return }
        let timeInterval = Date().timeIntervalSince(start)
        timer?.cancel() // Stop the timer
        
        if isPlayer1Turn {
            gameState.submitAnswer(player: 1, answer: answer, time: timeInterval)
        } else {
            gameState.submitAnswer(player: 2, answer: answer, time: timeInterval)
        }
        
        isPlayer1Turn.toggle()
        startTime = Date()
        startTimer() // Restart timer for next player
    }
    
    private func resetGame() {
        gameState.currentRound = 1
        gameState.player1Score = 0
        gameState.player2Score = 0
        gameState.isGameOver = false
        gameState.winner = nil
        gameState.player1Answer = nil
        gameState.player2Answer = nil
        gameState.usedQuestions.removeAll()
        gameState.selectNewQuestion()
        isPlayer1Turn = true
        startTime = Date()
        startTimer() // Start fresh timer
    }
    
    private func startTimer() {
        timer?.cancel()
        elapsedTime = 0
        timer = Timer.publish(every: 0.001, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.elapsedTime += 0.001
            }
    }
}

#Preview {
    ContentView()
}
