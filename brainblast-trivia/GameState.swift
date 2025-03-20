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
        guard let currentUser = cloudKit.currentUser else { return }
        
        if match.player1ID == currentUser.id || match.player2ID == currentUser.id {
            guard let questionID = UUID(uuidString: match.currentQuestionID),
                  let question = questions.first(where: { $0.id == questionID }) else { return }
            
            self.currentMatch = match
            self.currentQuestion = question
            self.currentRound = match.currentRound
            self.player1Score = match.player1Score
            self.player2Score = match.player2Score
            self.isMyTurn = match.player1ID == currentUser.id ? match.isPlayer1Turn : !match.isPlayer1Turn
            
            if let p1Answer = match.player1Answer, let p1Time = match.player1Time {
                self.player1Answer = (p1Answer, p1Time)
            }
            if let p2Answer = match.player2Answer, let p2Time = match.player2Time {
                self.player2Answer = (p2Answer, p2Time)
            }
            
            if isPlayer1 && match.player1Answer != nil && match.player2Answer != nil {
                let p1Correct = match.player1Answer == question.answer
                let p2Correct = match.player2Answer == question.answer
                
                if p1Correct && p2Correct {
                    roundWinner = match.player1Time! < match.player2Time! ? 1 : 2
                } else if p1Correct {
                    roundWinner = 1
                } else if p2Correct {
                    roundWinner = 2
                }
                
                self.showRoundResults = true
            }
        } else if match.player2ID == nil {
            var updatedMatch = match
            updatedMatch.player2ID = currentUser.id
            
            guard let questionID = UUID(uuidString: match.currentQuestionID),
                  let question = questions.first(where: { $0.id == questionID }) else { return }
            
            try await cloudKit.updateMatch(updatedMatch)
            
            self.currentMatch = updatedMatch
            self.currentQuestion = question
            self.currentRound = match.currentRound
            self.player1Score = match.player1Score
            self.player2Score = match.player2Score
            self.isMyTurn = !match.isPlayer1Turn
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
        }
        
        try await cloudKit.updateMatch(match)
        
        self.currentMatch = match
        self.isMyTurn = self.isPlayer1 ? !match.isPlayer1Turn : match.isPlayer1Turn

        if !self.isPlayer1 {
            self.showRoundResults = true
        }
    }
    
    func completeRound() async throws {
        guard var match = currentMatch else { return }
        
        match.player1Answer = nil
        match.player2Answer = nil
        match.player1Time = nil
        match.player2Time = nil
        
        player1Answer = nil
        player2Answer = nil
        roundWinner = nil
        
        if match.player1Score >= 3 || match.player2Score >= 3 {
            match.isCompleted = true
            winner = match.player1Score >= 3 ? 1 : 2
            isGameOver = true
        } else {
            match.currentRound += 1
            currentRound = match.currentRound
            selectNewQuestion()
            if let newQuestion = currentQuestion {
                match.currentQuestionID = newQuestion.id.uuidString
                match.previousQuestions.append(match.currentQuestionID)
            }
        }
        
        try await cloudKit.updateMatch(match)
        self.currentMatch = match
    }
    
    func selectNewQuestion() {
        let availableQuestions = questions.filter { !usedQuestions.contains($0.id) }
        if let question = availableQuestions.randomElement() {
            currentQuestion = question
            usedQuestions.insert(question.id)
        }
    }
}
