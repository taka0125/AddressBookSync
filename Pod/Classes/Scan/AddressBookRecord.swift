//
//  AddressBookRecord.swift
//  AddressBookSync
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation
import IDZSwiftCommonCrypto

public struct AddressBookRecord: CustomStringConvertible {
  public let id: String
  public let firstName: String
  public let lastName: String
  public let phoneNumbers: [String]
  public let emails: [String]
  
  public var description: String {
    return "(\(id), \(firstName), \(lastName), \(phoneNumbers.joinWithSeparator(", ")), \(emails.joinWithSeparator(", ")))"
  }
  
  public init(id: String, firstName: String, lastName: String, phoneNumbers: [String], emails: [String]) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.phoneNumbers = phoneNumbers.filter { !$0.isEmpty }
    self.emails = emails.filter { !$0.isEmpty }
  }
  
  public func hashCode() -> String? {
    let data = "\(id):\(firstName):\(lastName):\(phoneNumbers.joinWithSeparator(":")):\(emails.joinWithSeparator(":"))"
    
    if let digest = Digest(algorithm: .SHA256).update(data) {
      return hexStringFromArray(digest.final())
    }
    
    return nil
  }
}
