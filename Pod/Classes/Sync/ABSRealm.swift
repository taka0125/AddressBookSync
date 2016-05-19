//
//  ABSRealm.swift
//  AddressBookSync
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation
import RealmSwift

public struct ABSRealm {
  private static var config: Realm.Configuration = {
    var config = Realm.Configuration(objectTypes: [AddressBookRecordStatus.self])
    config.fileURL = config.fileURL?
      .URLByDeletingLastPathComponent?
      .URLByAppendingPathComponent("SyncHistoryStore")
      .URLByAppendingPathExtension("realm")
    return config
  }()
  
  static func instance() -> Realm {
    return try! Realm(configuration: config)
  }
  
  public static func removeStore() {
    guard let realmURL = config.fileURL else { return }
    
    let realmURLs = [
      realmURL,
      realmURL.URLByAppendingPathExtension("lock"),
      realmURL.URLByAppendingPathExtension("log_a"),
      realmURL.URLByAppendingPathExtension("log_b"),
      realmURL.URLByAppendingPathExtension("note")
    ]
    
    let manager = NSFileManager.defaultManager()
    realmURLs.forEach { URL in
      do {
        try manager.removeItemAtURL(URL)
      } catch {
      }
    }
  }
}
