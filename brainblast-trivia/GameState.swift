import Foundation
import CloudKit

@MainActor
class GameState: ObservableObject {
    @Published var currentRound = 1
    @Published var player1Score = 0
    @Published var player2Score = 0
    @Published var currentQuestion: TriviaQuestion?
    @Published var player1Answer: (answer: String, time: TimeInterval)?
    @Published var player2Answer: (answer: String, time: TimeInterval)?
    @Published var isGameOver = false
    @Published var winner: Int?
    @Published var currentMatch: Match?
    @Published var availableMatches: [Match] = []
    @Published var isMyTurn = false
    @Published var showRoundResults = false
    @Published var roundWinner: Int?
    
    private let cloudKit = CloudKitManager.shared
    var questions: [TriviaQuestion]
    var usedQuestions: Set<UUID> = []
    
    var isPlayer1: Bool {
        guard let match = currentMatch else { return false }
        return match.player1ID == cloudKit.currentUser?.id
    }
    
    init() {
        self.questions = TriviaQuestion.sampleQuestions
        Task {
            await loadAvailableMatches()
        }
    }
    
    func startNewGame() async throws {
        selectNewQuestion()
        guard let question = currentQuestion else { return }
        let match = try await cloudKit.createMatch(questionID: question.id.uuidString)
        self.currentMatch = match
        self.isMyTurn = true
    }
    
    func joinMatch(_ match: Match) async throws {
        print("[GameState] Attempting to join match with ID: \(match.id)")
        guard let currentUser = cloudKit.currentUser else {
            print("[GameState] Error: No current user")
            return
        }
        print("[GameState] Current user ID: \(currentUser.id)")
        
        if match.player1ID == currentUser.id || match.player2ID == currentUser.id {
            print("[GameState] Current user is player \(match.player1ID == currentUser.id ? "1" : "2")")
            guard let questionID = UUID(uuidString: match.currentQuestionID),
                  let question = questions.first(where: { $0.id == questionID }) else {
                print("[GameState] Error: Invalid question ID or question not found")
                return
            }
            
            self.currentMatch = match
            self.currentQuestion = question
            self.currentRound = match.currentRound
            self.player1Score = match.player1Score
            self.player2Score = match.player2Score
            self.isMyTurn = match.player1ID == currentUser.id ? match.isPlayer1Turn : !match.isPlayer1Turn
            print("[GameState] Successfully rejoined match")
        } else if match.player2ID == nil {
            print("[GameState] Attempting to join as player 2")
            var updatedMatch = match
            updatedMatch.player2ID = currentUser.id
            print("[GameState] Setting player2ID to: \(currentUser.id)")
            
            guard let questionID = UUID(uuidString: match.currentQuestionID),
                  let question = questions.first(where: { $0.id == questionID }) else {
                print("[GameState] Error: Invalid question ID or question not found")
                return
            }
            
            print("[GameState] Updating match in CloudKit...")
            try await cloudKit.updateMatch(updatedMatch)
            print("[GameState] Match updated successfully")
            
            self.currentMatch = updatedMatch
            self.currentQuestion = question
            self.currentRound = match.currentRound
            self.player1Score = match.player1Score
            self.player2Score = match.player2Score
            self.isMyTurn = !match.isPlayer1Turn
            print("[GameState] Successfully joined as player 2")
        } else {
            print("[GameState] Cannot join match: user is neither player 1 nor player 2")
        }
    }
    
    private func loadAvailableMatches() async {
        do {
            let matches = try await cloudKit.fetchOpenMatches()
            self.availableMatches = matches
        } catch {
            print("Error loading matches: \(error)")
        }
    }
    
    func submitAnswer(answer: String, time: TimeInterval) async throws {
        guard var match = currentMatch,
              let question = currentQuestion else { return }
        
        if isPlayer1 {
            player1Answer = (answer, time)
            match.player1Answer = answer
            match.player1Time = time
            match.isPlayer1Turn = false
        } else {
            player2Answer = (answer, time)
            match.player2Answer = answer
            match.player2Time = time
            match.isPlayer1Turn = true
            
            let p1Correct = match.player1Answer == question.answer
            let p2Correct = answer == question.answer
            
            if p1Correct && p2Correct {
                if match.player1Time! < time {
                    match.player1Score += 1
                    roundWinner = 1
                } else {
                    match.player2Score += 1
                    roundWinner = 2
                }
            } else if p1Correct {
                match.player1Score += 1
                roundWinner = 1
            } else if p2Correct {
                match.player2Score += 1
                roundWinner = 2
            }
            
            player1Score = match.player1Score
            player2Score = match.player2Score
            
            if match.player1Score >= 3 || match.player2Score >= 3 {
                match.isCompleted = true
                winner = match.player1Score >= 3 ? 1 : 2
                isGameOver = true
            } else {
                match.currentRound += 1
                currentRound = match.currentRound
                selectNewQuestion()
                match.currentQuestionID = currentQuestion?.id.uuidString ?? ""
                match.previousQuestions.append(match.currentQuestionID)
                
                player1Answer = nil
                player2Answer = nil
                roundWinner = nil
            }
        }
        
        try await cloudKit.updateMatch(match)
        
        self.currentMatch = match
        self.isMyTurn = self.isPlayer1 ? !match.isPlayer1Turn : match.isPlayer1Turn
        if !self.isPlayer1 {
            self.showRoundResults = true
        }
    }
    
    func selectNewQuestion() {
        let availableQuestions = questions.filter { !usedQuestions.contains($0.id) }
        if let question = availableQuestions.randomElement() {
            currentQuestion = question
            usedQuestions.insert(question.id)
        }
    }
}
