import SwiftUI
import Combine

extension Color {
    static let rainbowGradient = LinearGradient(
        gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let subtleRainbowGradient = LinearGradient(
        gradient: Gradient(colors: [
            .red.opacity(0.8),
            .orange.opacity(0.8),
            .yellow.opacity(0.8),
            .green.opacity(0.8),
            .blue.opacity(0.8),
            .purple.opacity(0.8)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @EnvironmentObject private var cloudKit: CloudKitManager
    @State private var isPlayer1Turn = true
    @State private var startTime: Date?
    @State private var showingAnswer = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: AnyCancellable?
    @State private var showingMatches = false
    @State private var submittedAnswer: String = ""
    @State private var opponentName: String = ""

    var formattedTime: String {
        let totalSeconds = Int(elapsedTime)
        let thousandths = Int((elapsedTime * 1000).truncatingRemainder(dividingBy: 1000))
        return String(format: "%02d:%03d", totalSeconds, thousandths)
    }

    var sortedMatches: [Match] {
        gameState.availableMatches.sorted { m1, m2 in
            (m1.modificationDate ?? .distantPast) > (m2.modificationDate ?? .distantPast)
        }
    }

    var body: some View {
        NavigationView {
            if gameState.currentMatch == nil {
                VStack {
                    HStack {
                        Text(cloudKit.currentUser?.name ?? "")
                            .font(.title)
                        
                        Spacer()
                        
                        Button("Logout") {
                            cloudKit.logout()
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                    
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .padding(.bottom, 40)
                    
                    Spacer().frame(height: 30)
                    
                    Button("Start New Game") {
                        Task {
                            try? await gameState.startNewGame()
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.rainbowGradient)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .font(.title2)
                    .shadow(radius: 5)
                    
                    Spacer()
                    
                    HStack {
                        Text("Available Matches")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                do {
                                    let matches = try await cloudKit.fetchOpenMatches()
                                    gameState.availableMatches = matches
                                    await gameState.fetchUserNames(for: matches)
                                } catch {
                                    print("Error loading matches: \(error)")
                                }
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(sortedMatches) { match in
                                Button(action: {
                                    Task {
                                        do {
                                            try await gameState.joinMatch(match)
                                        } catch {
                                            print("Error joining match: \(error)")
                                        }
                                    }
                                }) {
                                    HStack {
                                        if match.player1ID == cloudKit.currentUser?.id && match.player2ID == nil {
                                            Text("Waiting on an opponent...")
                                                .foregroundColor(.red)
                                        } else if match.player1ID == cloudKit.currentUser?.id {
                                            Text("You x \(gameState.userNames[match.player2ID!] ?? "someone") —\u{00A0}It's \(match.isPlayer1Turn ? "your turn!" : "their turn...")")
                                                .foregroundColor(match.isPlayer1Turn ? .green : .blue)
                                        } else if match.player2ID == cloudKit.currentUser?.id {
                                            Text("You x \(gameState.userNames[match.player1ID] ?? "someone") —\u{00A0}It's \(!match.isPlayer1Turn ? "your turn!" : "their turn...")")
                                                .foregroundColor(!match.isPlayer1Turn ? .green : .blue)
                                        } else {
                                            Text("Available to join \(gameState.userNames[match.player1ID] ?? "someone")'s match")
                                                .foregroundColor(.green)
                                        }
                                        Spacer()
                                        Text("Round \(match.currentRound)")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: UIScreen.main.bounds.height / 3)
                }
                .task {
                    do {
                        let matches = try await cloudKit.fetchOpenMatches()
                        gameState.availableMatches = matches
                        await gameState.fetchUserNames(for: matches)
                    } catch {
                        print("Error loading matches: \(error)")
                    }
                }
            } else {
                ZStack {
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(gameState.isPlayer1 ? "You" : opponentName)
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
                                Text(!gameState.isPlayer1 ? "You" : (gameState.currentMatch?.player2ID != nil ? opponentName : "TBD"))
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
                                if !gameState.showingAnswerConfirmation {
                                    Spacer()
                                    
                                    if !gameState.readyToStart {
                                        VStack(spacing: 20) {
                                            Text("Get Ready!")
                                                .font(.title)
                                                .padding()
                                            
                                            Button(action: {
                                                gameState.readyToStart = true
                                                startTime = Date()
                                                startTimer()
                                            }) {
                                                Text("Start")
                                                    .font(.title2)
                                                    .frame(minWidth: 200)
                                                    .padding()
                                                    .background(Color.blue)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                            }
                                            
                                            Button(action: {
                                                gameState.currentMatch = nil
                                            }) {
                                                Text("Back to Menu")
                                                    .font(.title2)
                                                    .frame(minWidth: 200)
                                                    .padding()
                                                    .background(Color.red)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                            }
                                        }
                                    } else {
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
                                    }
                                    
                                    Spacer()
                                } else {
                                    Spacer()
                                    VStack(spacing: 20) {
                                        Text(submittedAnswer == question.answer ? "Correct!" : "Incorrect")
                                            .font(.title)
                                            .foregroundColor(submittedAnswer == question.answer ? .green : .red)
                                            .padding()
                                        
                                        Text(String(format: "Your time: %.3f seconds", elapsedTime))
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                            .padding(.bottom)
                                        
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
                                Text(opponentName.isEmpty ? "Waiting for an opponent..." : "It's \(opponentName)'s turn")
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
                        gameState.readyToStart = false
                        gameState.showingAnswerConfirmation = false
                    }
                }
                .task {
                    if let match = gameState.currentMatch {
                        if gameState.isPlayer1 {
                            if let player2ID = match.player2ID {
                                opponentName = await CloudKitManager.shared.getUserName(for: player2ID) ?? "Player 2"
                            }
                        } else {
                            opponentName = await CloudKitManager.shared.getUserName(for: match.player1ID) ?? "Player 1"
                        }
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
                gameState.showingAnswerConfirmation = true
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
