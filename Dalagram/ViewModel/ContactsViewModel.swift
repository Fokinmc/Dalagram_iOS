//
//  ContactsViewModel.swift
//  Dalagram
//
//  Created by Toremurat on 01.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import Contacts
import SwiftyJSON
import RxSwift

class ContactsViewModel {
    
    var letters: [String] = []
    var phoneContacts: [(key: String, value:[PhoneContact])] = []
    var selectedContacts = Variable<[Int: Contact]>([:])
    var selectedIndex = Variable<Int>(0)
    
    // MARK: - Geting Contacts
    func getContacts(onSuccess: @escaping () -> Void) {
        NetworkManager.makeRequest(.getContacts(), success: { (json) in
            for (_, subJson):(String, JSON) in json["data"] {
                 Contact.initWith(json: subJson)
            }
            onSuccess()
        })
    }
    
    // MARK: - Fetching Contacts

    func fetchContacts(onSuccess: @escaping () -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Failed to request access to contacts \(error.localizedDescription)")
                return
            }
            if granted {
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                request.sortOrder = .userDefault
                do {
                    
                    /// Holder variables
                    var contactsDict: [String: [PhoneContact]] = [:] // Grouped dict "A": ["AName 1", "AName 2"] -
                    var contactsJsonDict: [[String: String]] = [] // Contacts as a Array ["Name 1", "Name 2"]
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopEnumeratingPointer) in
                        
                        /// Getting all objects
                        /// prefix - First letter of givenName or familyName
                        /// contactsObj - Single object which represent contact
                        
                        if let prefix = contact.familyName.first ?? contact.givenName.first, let phone = contact.phoneNumbers.first {
                            
                            let contactObj = PhoneContact(firstName: contact.givenName, lastName: contact.familyName, phone: phone.value.stringValue, image: contact.thumbnailImageData)
                            let contactJsonObj = ["phone": phone.value.stringValue, "contact_user_name": contactObj.getFullName()]
                            
                            /// Collecting contacts as a JSON Parameter for .addContacts request
                            contactsJsonDict.append(contactJsonObj)
                            
                            /// Collect all contacts with Dictionary<First letter of familyName : fullName>
                            if contactsDict[prefix.description] == nil {
                                contactsDict[prefix.description] = [contactObj]
                            } else {
                                contactsDict[prefix.description]?.append(contactObj)
                            }
                        }
                    })
                    
                    let sorted = contactsDict.sorted(by: { $0.0 < $1.0 })
                    self.phoneContacts = sorted
                    for item in sorted { self.letters.append(item.key) }
                    onSuccess()
                    
                    /// Adding contacts in order to know registered users
                    NetworkManager.makeRequest(.addContacts(contactsJsonDict), success: { (json) in
                        onSuccess()
                    }, failure: { _ in
                        onSuccess()
                    })
                    
                } catch let err {
                    print("Failed to enumerate contacts \(err)")
                    WhisperHelper.showErrorMurmur(title: "Failed to enumerate contacts \(err)")
                }
            } else {
                WhisperHelper.showErrorMurmur(title: "Ваши контакты не доступны")
            }
        }
    }
    
}
