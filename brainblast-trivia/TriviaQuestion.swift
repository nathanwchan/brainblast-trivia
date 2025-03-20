import Foundation

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let options: [String]
    
    // Sample questions for testing
    static let sampleQuestions = [
        TriviaQuestion(
            question: "If 3x + 7 = 22, what is the value of x?",
            answer: "5",
            options: ["3", "5", "7", "8"]
        ),
        TriviaQuestion(
            question: "What is the area of a circle with radius 4?",
            answer: "16π",
            options: ["8π", "12π", "16π", "20π"]
        )
    ]
}

