//
//  AddressBook.swift
//  AddressBookSync
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation

public struct AddressBook: AdapterProtocol {
  public static let sharedInstance = AddressBook()
  
  public enum Error: ErrorType {
    case RequestAccessFailed
  }
  
  private let adapter: AdapterProtocol
  
  private init() {
    if #available(iOS 9, *) {
      adapter = ContactsFrameworkBookAdapter()
    } else {
      adapter = AddressBookFrameworkAdapter()
    }
  }
  
  public func authorizationStatus() -> AuthorizationStatus {
    return adapter.authorizationStatus()
  }
  
  public func requestAccess(completionHandler: (Bool, ErrorType?) -> Void) {
    return adapter.requestAccess(completionHandler)
  }
  
  public func fetchAll() -> [AddressBookRecord] {
    return adapter.fetchAll()
  }
}