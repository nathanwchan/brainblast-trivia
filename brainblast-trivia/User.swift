import Foundation
import CloudKit

// Modified User struct with Codable conformance
struct User: Identifiable, Codable {
    let id: String
    var name: String
    let recordID: CKRecord.ID
    
    // Update User init from CKRecord
    init(record: CKRecord) {
        self.id = record["id"] as? String ?? record.recordID.recordName
        self.name = record["name"] as? String ?? ""
        self.recordID = record.recordID
        
        // Make sure to save the recordID to a queryable field
        record["recordIDName"] = record.recordID.recordName
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
    
    // Update Codable conformance to use recordIDName
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case recordIDName
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
