import Foundation
import CloudKit

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let options: [String]
    
    init(record: CKRecord) {
        self.question = record["question"] as? String ?? ""
        self.answer = record["answer"] as? String ?? ""
        self.options = record["options"] as? [String] ?? []
    }
    
    init(question: String, answer: String, options: [String]) {
        self.question = question
        self.answer = answer
        self.options = options
    }
    
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
