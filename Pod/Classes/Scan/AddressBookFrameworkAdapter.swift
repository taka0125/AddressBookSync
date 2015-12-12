//
//  AddressBookFrameworkAdapter.swift
//  AddressBookSync
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation
import AddressBook

public struct AddressBookFrameworkAdapter: AdapterProtocol {
  public func authorizationStatus() -> AuthorizationStatus {
    let status = ABAddressBookGetAuthorizationStatus()
    switch status {
    case .NotDetermined: return .NotDetermined
    case .Restricted: return .Restricted
    case .Denied: return .Denied
    case .Authorized: return .Authorized
    }
  }
  
  public func requestAccess(completionHandler: (Bool, ErrorType?) -> Void) {
    let addressBookRef = buildAddressBookRef()
    ABAddressBookRequestAccessWithCompletion(addressBookRef) { (granted, error) in
      completionHandler(granted, error == nil ? nil : AddressBook.Error.RequestAccessFailed)
    }
  }
  
  public func fetchAll() -> [AddressBookRecord] {
    var records = [AddressBookRecord]()
    let addressBookRef = buildAddressBookRef()
    let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as Array
    
    allContacts.forEach { contact in
      let id = "\(ABRecordGetRecordID(contact))"
      let firstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty).takeRetainedValue() as! String
      let lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty).takeRetainedValue() as! String
      
      let phoneNumbersRef = ABRecordCopyValue(contact, kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValueRef
      let phoneNumbers = Array(0..<ABMultiValueGetCount(phoneNumbersRef))
        .map { (ABMultiValueCopyValueAtIndex(phoneNumbersRef, $0).takeUnretainedValue() as? String) ?? "" }
        .filter { !$0.isEmpty }
        .ads_unique
      
      let emailsRef = ABRecordCopyValue(contact, kABPersonEmailProperty).takeUnretainedValue() as ABMultiValueRef
      let emails = Array(0..<ABMultiValueGetCount(emailsRef))
        .map { (ABMultiValueCopyValueAtIndex(emailsRef, $0).takeUnretainedValue() as? String) ?? "" }
        .filter { !$0.isEmpty }
        .ads_unique
      
      records.append(AddressBookRecord(id: id, firstName: firstName, lastName: lastName, phoneNumbers: phoneNumbers, emails: emails))
    }
    
    return records
  }
}

extension AddressBookFrameworkAdapter {
  private func buildAddressBookRef() -> ABAddressBookRef {
    return ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
  }
}

private extension Array where Element: Hashable {
  var ads_unique: [Element] {
    return Array(Set(self))
  }
}