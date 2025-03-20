import Foundation
import CloudKit

struct TriviaQuestion: Identifiable {
    let id: UUID  
    let question: String
    let answer: String
    let options: [String]
    
    init(record: CKRecord) {
        // Generate UUID from record ID or create a new one
        if let uuidString = record["id"] as? String,
           let uuid = UUID(uuidString: uuidString) {
            self.id = uuid
        } else {
            self.id = UUID()
        }
        
        self.question = record["question"] as? String ?? ""
        self.answer = record["answer"] as? String ?? ""
        self.options = record["options"] as? [String] ?? []
    }
    
    init(id: UUID = UUID(), question: String, answer: String, options: [String]) {
        self.id = id
        self.question = question
        self.answer = answer
        self.options = options
    }
    
    static let sampleQuestions = [
        TriviaQuestion(
            id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "If 3x + 7 = 22, what is the value of x?",
            answer: "5",
            options: ["3", "5", "7", "8"]
        ),
        TriviaQuestion(
            id: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            question: "What is the area of a circle with radius 4?",
            answer: "16π",
            options: ["8π", "12π", "16π", "20π"]
        )
    ]
}
