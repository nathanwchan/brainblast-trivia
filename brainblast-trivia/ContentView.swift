import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @EnvironmentObject private var cloudKit: CloudKitManager
    @State private var isPlayer1Turn = true
    @State private var startTime: Date?
    @State private var showingAnswer = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: AnyCancellable?
    @State private var showingMatches = false
    @State private var showingAnswerConfirmation = false
    @State private var submittedAnswer: String = ""

    var formattedTime: String {
        let totalSeconds = Int(elapsedTime)
        let thousandths = Int((elapsedTime * 1000).truncatingRemainder(dividingBy: 1000))
        return String(format: "%02d:%03d", totalSeconds, thousandths)
    }

    var body: some View {
        NavigationView {
            if gameState.currentMatch == nil {
                VStack {
                    Text("Welcome, \(cloudKit.currentUser?.name ?? "")!")
                        .font(.title)
                        .padding()
                    
                    Button("Start New Game") {
                        Task {
                            try? await gameState.startNewGame()
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Join Game") {
                        showingMatches = true
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Logout") {
                        cloudKit.logout()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showingMatches) {
                    MatchListView(gameState: gameState)
                }
            } else {
                ZStack {
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(gameState.isPlayer1 ? "You" : "Opponent")
                                    .font(.headline)
                                Text("Score: \(gameState.player1Score)")
                            }
                            .padding()
                            .background(gameState.isPlayer1 ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(10)
                            
                            Spacer()
                            
                            VStack {
                                Text("Round \(gameState.currentRound)")
                                    .font(.headline)
                                if gameState.isMyTurn {
                                    Text("Your Turn!")
                                        .foregroundColor(.green)
                                } else {
                                    Text("Waiting...")
                                        .foregroundColor(.red)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(!gameState.isPlayer1 ? "You" : (gameState.currentMatch?.player2ID != nil ? "Opponent" : "TBD"))
                                    .font(.headline)
                                Text("Score: \(gameState.player2Score)")
                            }
                            .padding()
                            .background(!gameState.isPlayer1 ? Color.green.opacity(0.2) : Color.clear)
                            .cornerRadius(10)
                        }
                        .padding()
                        
                        if let question = gameState.currentQuestion {
                            if gameState.isMyTurn {
                                if !showingAnswerConfirmation {
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
                                                submittedAnswer = option
                                                Task {
                                                    await submitAnswer(option)
                                                }
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
                                } else {
                                    Spacer()
                                    VStack(spacing: 20) {
                                        Text(submittedAnswer == question.answer ? "Correct!" : "Incorrect")
                                            .font(.title)
                                            .foregroundColor(submittedAnswer == question.answer ? .green : .red)
                                            .padding()
                                        
                                        Text(question.question)
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                        
                                        VStack(spacing: 10) {
                                            Text("Your answer: \(submittedAnswer)")
                                                .font(.title2)
                                            
                                            if submittedAnswer != question.answer {
                                                Text("Correct answer: \(question.answer)")
                                                    .font(.title2)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding()
                                        
                                        Text("Waiting for another player...")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                            .padding()
                                        
                                        Button("Back to Menu") {
                                            gameState.currentMatch = nil
                                        }
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                    Spacer()
                                }
                            } else {
                                Spacer()
                                Text("Waiting for another player...")
                                    .font(.title2)
                                
                                Button("Back to Menu") {
                                    gameState.currentMatch = nil
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                
                                Spacer()
                            }
                        }
                    }
                    .blur(radius: gameState.showRoundResults ? 10 : 0)
                    
                    if gameState.showRoundResults {
                        RoundResultsView(gameState: gameState)
                            .transition(.scale)
                    }
                }
                .onAppear {
                    if gameState.isMyTurn {
                        startTime = Date()
                        startTimer()
                        showingAnswerConfirmation = false
                    }
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
        }
    }
    
    private func submitAnswer(_ answer: String) async {
        guard let start = startTime else { return }
        let timeInterval = Date().timeIntervalSince(start)
        timer?.cancel()
        
        await MainActor.run {
            withAnimation {
                showingAnswerConfirmation = true
            }
        }
        
        try? await gameState.submitAnswer(answer: answer, time: timeInterval)
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
        startTimer()
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
