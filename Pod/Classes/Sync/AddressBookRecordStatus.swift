//
//  AddressBookRecordStatus.swift
//  AddressBookSync
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation
import RealmSwift

public final class AddressBookRecordStatus: Object {
  public dynamic var recordId = ""
  public dynamic var hashCode = ""
  public dynamic var deleted = false
  public dynamic var verifiedAt: Double = 0.0
  public dynamic var updatedAt: Double = 0.0
  public dynamic var syncedAt: Double = 0.0
  
  public override static func primaryKey() -> String? {
    return "recordId"
  }
  
  public func isChanged(record: AddressBookRecord) -> Bool {
    guard let hashCode = record.hashCode() else { return false }
    return self.hashCode != hashCode
  }
  
  public class func find(realm: Realm, recordId: String) -> AddressBookRecordStatus? {
    return realm.objectForPrimaryKey(self, key: recordId)
  }
  
  public class func needSyncRecordIds(realm: Realm) -> [String] {
    let objects = realm.objects(self)
    return objects.filter("updatedAt >= syncedAt and deleted == false").map { $0.recordId }
  }

  public class func markAsDelete(realm: Realm, timestamp: NSTimeInterval) {
    try! realm.write {
      let results = realm.objects(self).filter("verifiedAt < %lf", timestamp)
      results.forEach { result in
        result.deleted = true
        result.updatedAt = timestamp
      }
    }
  }
  
  public class func markAsSynced(realm: Realm, recordIds: [String], timestamp: NSTimeInterval) {
    let results = realm.objects(self).filter(NSPredicate(format: "recordId IN %@", recordIds))
    
    try! realm.write {
      results.forEach { result in
        result.syncedAt = timestamp
      }
    }
  }
}