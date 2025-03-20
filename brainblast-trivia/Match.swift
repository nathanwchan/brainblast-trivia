import Foundation
import CloudKit

struct Match: Identifiable {
    let id: String
    let player1ID: String
    var player2ID: String?
    var currentRound: Int
    var player1Score: Int
    var player2Score: Int
    var currentQuestionID: String
    var previousQuestions: [String]
    var player1Answer: String?
    var player2Answer: String?
    var player1Time: TimeInterval?
    var player2Time: TimeInterval?
    var isPlayer1Turn: Bool
    var isCompleted: Bool
    let recordID: CKRecord.ID
    
    init(record: CKRecord) {
        self.id = record.recordID.recordName
        self.player1ID = record["player1ID"] as? String ?? ""
        self.player2ID = record["player2ID"] as? String
        self.currentRound = record["currentRound"] as? Int ?? 1
        self.player1Score = record["player1Score"] as? Int ?? 0
        self.player2Score = record["player2Score"] as? Int ?? 0
        self.currentQuestionID = record["currentQuestionID"] as? String ?? ""
        self.previousQuestions = record["previousQuestions"] as? [String] ?? []
        self.player1Answer = record["player1Answer"] as? String
        self.player2Answer = record["player2Answer"] as? String
        self.player1Time = record["player1Time"] as? TimeInterval
        self.player2Time = record["player2Time"] as? TimeInterval
        self.isPlayer1Turn = record["isPlayer1Turn"] as? Bool ?? true
        self.isCompleted = record["isCompleted"] as? Bool ?? false
        self.recordID = record.recordID
    }
    
    init(player1ID: String, questionID: String) {
        self.id = UUID().uuidString
        self.player1ID = player1ID
        self.currentRound = 1
        self.player1Score = 0
        self.player2Score = 0
        self.currentQuestionID = questionID
        self.previousQuestions = [questionID]
        self.isPlayer1Turn = true
        self.isCompleted = false
        self.recordID = CKRecord.ID(recordName: id)
    }
}
