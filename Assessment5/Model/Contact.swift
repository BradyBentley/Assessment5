//
//  Contact.swift
//  Assessment5
//
//  Created by Brady Bentley on 1/4/19.
//  Copyright © 2019 Brady. All rights reserved.
//

import Foundation
import CloudKit

class Contact {
    // MARK: - Properties
    var name: String
    var phoneNumber: Int?
    var email: String?
    
    // CloudKit
    let ckRecordId: CKRecord.ID
    
    // MARK: - Keys
    enum ContactKeys {
        static let recordKey = "Contact"
        static let nameKey = "name"
        static let phoneNumberKey = "phoneNumber"
        static let emailKey = "email"
    }
    
    // MARK: - Initialization
    init(name: String, phoneNumber: Int, email: String, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.ckRecordId = ckRecordId
    }
    
    convenience init?(ckRecord: CKRecord){
        guard let name = ckRecord[ContactKeys.nameKey] as? String,
            let phoneNumber = ckRecord[ContactKeys.phoneNumberKey] as? Int,
            let email = ckRecord[ContactKeys.emailKey] as? String else { return nil }
        self.init(name: name, phoneNumber: phoneNumber, email: email, ckRecordId: ckRecord.recordID)
    }
}

// MARK: - CKRecord Extension
extension CKRecord {
    convenience init(contact: Contact){
        self.init(recordType: Contact.ContactKeys.recordKey, recordID: contact.ckRecordId)
        self.setValue(contact.name, forKey: Contact.ContactKeys.nameKey)
        self.setValue(contact.phoneNumber, forKey: Contact.ContactKeys.phoneNumberKey)
        self.setValue(contact.email, forKey: Contact.ContactKeys.emailKey)
    }
}

// MARK: - Equatable
extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.email == rhs.email && lhs.phoneNumber == rhs.phoneNumber && lhs.name == rhs.name && lhs.ckRecordId == rhs.ckRecordId
    }
}
