import Foundation
import CloudKit

// Modified User struct with Codable conformance
struct User: Identifiable, Codable {
    let id: String
    var name: String
    let recordID: CKRecord.ID
    
    init(record: CKRecord) {
        self.id = record.recordID.recordName
        self.name = record["name"] as? String ?? ""
        self.recordID = record.recordID
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.recordID = CKRecord.ID(recordName: id)
    }
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.recordID = CKRecord.ID(recordName: id)
    }
    
    // Add Codable conformance
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case recordIDName = "recordID"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(recordID.recordName, forKey: .recordIDName)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let recordName = try container.decode(String.self, forKey: .recordIDName)
        recordID = CKRecord.ID(recordName: recordName)
    }
}
