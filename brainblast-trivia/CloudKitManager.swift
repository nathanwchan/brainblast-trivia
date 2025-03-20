import Foundation
import CloudKit

class CloudKitManager: ObservableObject {
    // Singleton instance
    static let shared = CloudKitManager()
    
    // Container and database properties
    private let container: CKContainer
    private let database: CKDatabase
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var containerStatus: String?
    
    // Add cache for user names
    private var userNameCache: [String: String] = [:]
    
    private init() {
        self.container = CKContainer(identifier: "iCloud.com.natechan.brainblast-2")
        self.database = container.publicCloudDatabase
        
        // Load saved user if exists
        if let savedUserData = UserDefaults.standard.data(forKey: "currentUser"),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedUserData) {
            self.currentUser = savedUser
            self.isAuthenticated = true
        }
        
        // Verify container and setup schema
        Task {
            do {
                try await verifyAndSetupSchema()
            } catch {
                print("Schema setup error: \(error)")
            }
        }
    }
    
    private func verifyAndSetupSchema() async throws {
        // Check container status
        let status = try await container.accountStatus()
        
        DispatchQueue.main.async {
            switch status {
            case .available:
                self.containerStatus = nil // "iCloud Status: Available"
            case .noAccount:
                self.containerStatus = "Error: No iCloud account"
            case .restricted:
                self.containerStatus = "Error: iCloud restricted"
            case .couldNotDetermine:
                self.containerStatus = "Error: Could not determine iCloud status"
            case .temporarilyUnavailable:
                self.containerStatus = "Error: iCloud temporarily unavailable"
            @unknown default:
                self.containerStatus = "Error: Unknown iCloud status"
            }
        }
        
        // Create test records to ensure schema exists
        let testUser = CKRecord(recordType: "User")
        testUser["name"] = "test"
        testUser["id"] = "test-id"  // Add id field to schema
        
        let testMatch = CKRecord(recordType: "Match")
        testMatch["player1ID"] = "test"
        testMatch["currentQuestionID"] = "test"
        testMatch["previousQuestions"] = ["test"]
        testMatch["currentRound"] = 1
        testMatch["player1Score"] = 0
        testMatch["player2Score"] = 0
        testMatch["isPlayer1Turn"] = true
        testMatch["isCompleted"] = false
        
        do {
            _ = try await database.save(testUser)
            _ = try await database.save(testMatch)
            
            // Clean up test records
            try await database.deleteRecord(withID: testUser.recordID)
            try await database.deleteRecord(withID: testMatch.recordID)
            
            print("Schema setup successful")
        } catch {
            print("Failed to setup schema: \(error)")
            throw error
        }
    }
    
    func authenticate(name: String) async throws -> User {
        let predicate = NSPredicate(format: "name == %@", name)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        do {
            let result = try await database.records(matching: query)
            let records = result.matchResults.compactMap { try? $0.1.get() }
            
            let user: User
            if let existingRecord = records.first {
                user = User(record: existingRecord)
            } else {
                // Create new user record
                let newUserRecord = CKRecord(recordType: "User")
                let userID = UUID().uuidString
                newUserRecord["name"] = name
                newUserRecord["id"] = userID
                
                let savedRecord = try await database.save(newUserRecord)
                user = User(record: savedRecord)
            }
            
            // Save user to UserDefaults
            if let encodedUser = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encodedUser, forKey: "currentUser")
            }
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
            }
            return user
        } catch {
            print("Authentication error: \(error)")
            throw error
        }
    }
    
    func createMatch(questionID: String) async throws -> Match {
        guard let currentUser = currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let record = CKRecord(recordType: "Match")
        record["player1ID"] = currentUser.id
        record["currentQuestionID"] = questionID
        record["previousQuestions"] = [questionID]
        record["currentRound"] = 1
        record["player1Score"] = 0
        record["player2Score"] = 0
        record["isPlayer1Turn"] = true
        record["isCompleted"] = false
        
        let savedRecord = try await database.save(record)
        return Match(record: savedRecord)
    }
    
    func updateMatch(_ match: Match) async throws {
        print("[CloudKit] Updating match with ID: \(match.id)")
        print("[CloudKit] Player2ID being set to: \(match.player2ID ?? "nil")")
        
        // Fetch the existing record first
        let record = try await database.record(for: match.recordID)
        print("[CloudKit] Found existing record: \(record.recordID.recordName)")
        
        // Update the record with new values
        record["player1ID"] = match.player1ID
        record["player2ID"] = match.player2ID
        record["currentRound"] = match.currentRound
        record["player1Score"] = match.player1Score
        record["player2Score"] = match.player2Score
        record["currentQuestionID"] = match.currentQuestionID
        record["previousQuestions"] = match.previousQuestions
        record["player1Answer"] = match.player1Answer
        record["player2Answer"] = match.player2Answer
        record["player1Time"] = match.player1Time
        record["player2Time"] = match.player2Time
        record["isPlayer1Turn"] = match.isPlayer1Turn
        record["isCompleted"] = match.isCompleted
        
        print("[CloudKit] Saving updated record...")
        let savedRecord = try await database.save(record)
        print("[CloudKit] Record saved successfully. Player2ID in saved record: \(savedRecord["player2ID"] ?? "nil")")
    }
    
    func fetchOpenMatches() async throws -> [Match] {
        let predicate = NSPredicate(format: "isCompleted == NO")
        let query = CKQuery(recordType: "Match", predicate: predicate)
        
        let result = try await database.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        return records.map { Match(record: $0) }
    }
    
    func deleteAllMatches() async throws {
        // First fetch open matches using our existing function
        let matches = try await fetchOpenMatches()
        
        // Delete each match record individually
        for match in matches {
            try await database.deleteRecord(withID: match.recordID)
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
            UserDefaults.standard.removeObject(forKey: "currentUser")
        }
    }
    
    func getUserName(for userID: String) async -> String? {
            // Return from cache if available
            if let cachedName = userNameCache[userID] {
                return cachedName
            }
            
            do {
                let predicate = NSPredicate(format: "id == %@", userID)
                let query = CKQuery(recordType: "User", predicate: predicate)
                
                let result = try await database.records(matching: query)
                let records = result.matchResults.compactMap { try? $0.1.get() }
                
                if let record = records.first,
                   let name = record["name"] as? String {
                    DispatchQueue.main.async {
                        self.userNameCache[userID] = name
                    }
                    return name
                } else {
                    print("[CloudKit] No valid name found in records")
                }
            } catch {
                print("[CloudKit] Error fetching user name for \(userID): \(error)")
            }
            
            // Fallback: return a placeholder
            let fallbackName = "Unknown"
            DispatchQueue.main.async {
                self.userNameCache[userID] = fallbackName
            }
            return fallbackName
    }
}
