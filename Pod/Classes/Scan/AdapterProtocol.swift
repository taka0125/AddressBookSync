//
//  AdapterProtocol.swift
//  AddressBookSync
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation

public protocol AdapterProtocol {
  func authorizationStatus() -> AuthorizationStatus
  func requestAccess(completionHandler: (Bool, ErrorType?) -> Void)
  func fetchAll() -> [AddressBookRecord]
}