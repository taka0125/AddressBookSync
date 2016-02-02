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
    config.path = NSURL.fileURLWithPath(config.path!)
      .URLByDeletingLastPathComponent?
      .URLByAppendingPathComponent("SyncHistoryStore")
      .URLByAppendingPathExtension("realm")
      .path
    return config
  }()
  
  static func instance() -> Realm {
    return try! Realm(configuration: config)
  }
  
  public static func removeStore() {
    guard let pathString = config.path else { return }
    
    let manager = NSFileManager.defaultManager()
    let path = NSURL(fileURLWithPath: pathString)
    let realmPaths = [
      path,
      path.URLByAppendingPathExtension("lock"),
      path.URLByAppendingPathExtension("log_a"),
      path.URLByAppendingPathExtension("log_b"),
      path.URLByAppendingPathExtension("note")
    ]
    
    realmPaths.forEach { URL in
      do {
        try manager.removeItemAtURL(URL)
      } catch {
      }
    }
  }
}
