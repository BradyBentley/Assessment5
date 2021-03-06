//
//  ContactController.swift
//  Assessment5
//
//  Created by Brady Bentley on 1/4/19.
//  Copyright © 2019 Brady. All rights reserved.
//

import Foundation
import CloudKit

typealias successCompletion = (_ success: Bool) -> Void

class ContactController {
    // MARK: - Properties
    static let shared = ContactController() ; private init(){}
    var contacts: [Contact] = []
    
    // MARK: - CRUD
    // create
    func createContactWith(name: String, phoneNumber: Int, email: String, completion: @escaping successCompletion) {
        let newContact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        save(contact: newContact) { (success) in
            completion(success)
        }
    }
    
    func save(contact: Contact, completion: @escaping successCompletion) {
        let contactToSave = CKRecord(contact: contact)
        CKContainer.default().privateCloudDatabase.save(contactToSave) { (record, error) in
            if let error = error {
                print("Error in saving contact: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let record = record, let validatedRecord = Contact(ckRecord: record) else { completion(false) ; return }
            self.contacts.append(validatedRecord)
            completion(true)
        }
    }
    
    // Read
    func fetchAllContacts(completion: @escaping successCompletion) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Contact.ContactKeys.recordKey, predicate: predicate)
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in fetching contacts: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let records = records else { completion(false) ; return }
            let contacts = records.compactMap { Contact(ckRecord: $0) }
            self.contacts = contacts
            completion(true)
        }
    }
    
    //update
    func updateContact(contact: Contact, name: String, phoneNumber: Int, email: String, completion: @escaping successCompletion) {
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.email = email
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: contact.ckRecordId) { (record, error) in
            if let error = error {
                print("Error fetching contacts to update: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let record = record else { return }
            record[Contact.ContactKeys.nameKey] = name
            record[Contact.ContactKeys.phoneNumberKey] = phoneNumber
            record[Contact.ContactKeys.emailKey] = email
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recordIds, error) in
                completion(true)
            }
            CKContainer.default().privateCloudDatabase.add(operation)
        }
    }
    
    func deleteContact(contact: Contact, completion: @escaping successCompletion) {
        guard let index = contacts.index(of: contact) else { completion(false) ; return }
        contacts.remove(at: index)
        CKContainer.default().privateCloudDatabase.delete(withRecordID: contact.ckRecordId) { (_, error) in
            if let error = error {
                print("Error deleting contact: \(error.localizedDescription)")
                completion(false)
                return
            } else {
                completion(true)
            }
        }
    }
}
