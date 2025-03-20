import Foundation
import CloudKit

struct User: Identifiable {
    let id: String
    var name: String
    let recordID: CKRecord.ID
    
    init(record: CKRecord) {
        self.id = record.recordID.recordName
        self.name = record["name"] as? String ?? ""
        self.recordID = record.recordID
    }
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.recordID = CKRecord.ID(recordName: id)
    }
}
