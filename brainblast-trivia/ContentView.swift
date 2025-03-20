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
                .navigationBarItems(trailing: Button("Logout") {
                    cloudKit.logout()
                })
            }
        }
    }
    
    private func submitAnswer(_ answer: String) async {
        guard let start = startTime else { return }
        let timeInterval = Date().timeIntervalSince(start)
        timer?.cancel()
        
        withAnimation {
            showingAnswerConfirmation = true
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

struct MatchListView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var cloudKit: CloudKitManager
    @State private var userNames: [String: String] = [:]
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false

    var body: some View {
        NavigationView {
            List(gameState.availableMatches) { match in
                Button(action: {
                    Task {
                        do {
                            try await gameState.joinMatch(match)
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Error joining match: \(error)")
                        }
                    }
                }) {
                    HStack {
                        if match.player1ID == cloudKit.currentUser?.id {
                            Text("Your game")
                                .foregroundColor(.blue)
                        } else {
                            Text(userNames[match.player1ID] ?? "Loading...")
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Text("Round \(match.currentRound)")
                            .foregroundColor(.gray)
                    }
                }
                .disabled(isDeleting)
            }
            .navigationTitle("Available Matches")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Text("Delete All")
                            .foregroundColor(.red)
                    }
                    .disabled(isDeleting)
                }
            }
            .alert("Delete All Matches?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        isDeleting = true
                        do {
                            try await cloudKit.deleteAllMatches()
                            gameState.availableMatches = []
                        } catch {
                            print("Error deleting matches: \(error)")
                        }
                        isDeleting = false
                    }
                }
            } message: {
                Text("This will delete all matches in the game. This action cannot be undone.")
            }
            .task {
                // Load all matches and usernames when view appears
                do {
                    let matches = try await cloudKit.fetchOpenMatches()
                    gameState.availableMatches = matches
                    
                    for match in matches {
                        if userNames[match.player1ID] == nil {
                            if let name = await cloudKit.getUserName(for: match.player1ID) {
                                userNames[match.player1ID] = name
                            }
                        }
                    }
                } catch {
                    print("Error loading matches: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
