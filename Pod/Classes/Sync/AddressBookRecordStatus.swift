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

final class AddressBookRecordStatus: Object {
  dynamic var recordId = ""
  dynamic var hashCode = ""
  dynamic var deleted = false
  dynamic var verifiedAt: Double = 0.0
  dynamic var updatedAt: Double = 0.0
  dynamic var syncedAt: Double = 0.0
  
  override static func primaryKey() -> String? {
    return "recordId"
  }
  
  override static func indexedProperties() -> [String] {
    return ["deleted"]
  }
  
  func isChanged(record: AddressBookRecord) -> Bool {
    guard let hashCode = record.hashCode() else { return false }
    return self.hashCode != hashCode
  }
  
  class func find(recordId: String) -> AddressBookRecordStatus? {
    return ABSRealm.instance().objectForPrimaryKey(self, key: recordId)
  }
  
  class func needSyncRecordIds() -> [String] {
    let objects = ABSRealm.instance().objects(self)
    return objects.filter("updatedAt >= syncedAt and deleted == false").map { $0.recordId }
  }

  class func fetchAllDeletedRecordIds() -> [String] {
    let objects = ABSRealm.instance().objects(self)
    return objects.filter("deleted == true").map { $0.recordId }
  }

  class func markAsDelete(timestamp: NSTimeInterval) {
    let realm = ABSRealm.instance()
    let results = realm.objects(self).filter("verifiedAt < %lf", timestamp)
    results.setValue(true, forKeyPath: "deleted")
    results.setValue(timestamp, forKeyPath: "updatedAt")
  }
  
  class func markAsSynced(recordIds: [String], timestamp: NSTimeInterval) {
    let realm = ABSRealm.instance()
    let results = realm.objects(self).filter("recordId IN %@", recordIds)
    
    results.setValue(timestamp, forKeyPath: "syncedAt")
  }

  class func destoryAllDeletedRecords(recordIds: [String]) {
    let realm = ABSRealm.instance()
    let results = realm.objects(self).filter("deleted == true and recordId IN %@", recordIds)

    realm.delete(results)
  }
}
