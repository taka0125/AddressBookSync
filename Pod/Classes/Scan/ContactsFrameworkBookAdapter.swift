//
//  ContactsFrameworkBookAdapter.swift
//  AddressBookSync
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation
import Contacts

@available(iOS 9.0, *)
public struct ContactsFrameworkBookAdapter: AdapterProtocol {
  public func authorizationStatus() -> AuthorizationStatus {
    let status = CNContactStore.authorizationStatusForEntityType(.Contacts)
    switch status {
    case .NotDetermined: return .NotDetermined
    case .Restricted: return .Restricted
    case .Denied: return .Denied
    case .Authorized: return .Authorized
    }
  }
  
  public func requestAccess(completionHandler: (Bool, ErrorType?) -> Void) {
    CNContactStore().requestAccessForEntityType(.Contacts) { (granted, error) in
      completionHandler(granted, error == nil ? nil : AddressBook.Error.RequestAccessFailed)
    }
  }
  
  public func fetchAll() -> [AddressBookRecord] {
    var records = [AddressBookRecord]()

    let store = CNContactStore()
    let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey])
    
    let _ = try? store.enumerateContactsWithFetchRequest(fetchRequest) { (contact, stop) in
      let id = contact.identifier
      let firstName = contact.givenName
      let lastName = contact.familyName
      
      let phoneNumbers = contact.phoneNumbers
        .map { $0.value as? CNPhoneNumber }
        .flatMap { $0?.stringValue ?? "" }
        .filter { !$0.isEmpty }
        .ads_unique
      
      let emails = contact.emailAddresses
        .map { $0.value as? String }
        .flatMap { $0 ?? "" }
        .filter { !$0.isEmpty }
        .ads_unique
      
      records.append(AddressBookRecord(id: id, firstName: firstName, lastName: lastName, phoneNumbers: phoneNumbers, emails: emails))
    }
    
    return records
  }
}

private extension Array where Element: Hashable {
  var ads_unique: [Element] {
    return Array(Set(self))
  }
}