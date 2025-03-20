import Foundation

class GameState: ObservableObject {
    @Published var currentRound = 1
    @Published var player1Score = 0
    @Published var player2Score = 0
    @Published var currentQuestion: TriviaQuestion?
    @Published var player1Answer: (answer: String, time: TimeInterval)?
    @Published var player2Answer: (answer: String, time: TimeInterval)?
    @Published var isGameOver = false
    @Published var winner: Int? // 1 for player 1, 2 for player 2
    
    var questions: [TriviaQuestion]
    var usedQuestions: Set<UUID> = []
    
    init() {
        self.questions = TriviaQuestion.sampleQuestions
        selectNewQuestion()
    }
    
    func selectNewQuestion() {
        let availableQuestions = questions.filter { !usedQuestions.contains($0.id) }
        if let question = availableQuestions.randomElement() {
            currentQuestion = question
            usedQuestions.insert(question.id)
        }
    }
    
    func submitAnswer(player: Int, answer: String, time: TimeInterval) {
        if player == 1 {
            player1Answer = (answer, time)
        } else {
            player2Answer = (answer, time)
        }
        
        if player1Answer != nil && player2Answer != nil {
            evaluateRound()
        }
    }
    
    private func evaluateRound() {
        guard let p1Answer = player1Answer,
              let p2Answer = player2Answer,
              let question = currentQuestion else { return }
        
        let p1Correct = p1Answer.answer == question.answer
        let p2Correct = p2Answer.answer == question.answer
        
        if p1Correct && p2Correct {
            // Both correct, faster player wins
            if p1Answer.time < p2Answer.time {
                player1Score += 1
            } else if p2Answer.time < p1Answer.time {
                player2Score += 1
            }
        } else if p1Correct {
            player1Score += 1
        } else if p2Correct {
            player2Score += 1
        }
        
        // Check for game over
        if player1Score >= 3 {
            isGameOver = true
            winner = 1
        } else if player2Score >= 3 {
            isGameOver = true
            winner = 2
        } else {
            // Reset for next round
            currentRound += 1
            player1Answer = nil
            player2Answer = nil
            selectNewQuestion()
        }
    }
}

