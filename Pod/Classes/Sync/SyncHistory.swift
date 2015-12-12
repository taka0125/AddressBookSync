//
//  SyncHistory.swift
//  AddressBookSync
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation
import RealmSwift

public struct SyncHistory {
  public static let sharedInstance = SyncHistory()
  
  private var config: Realm.Configuration
  
  private init() {
    var config = Realm.Configuration()
    config.path = NSURL.fileURLWithPath(config.path!)
      .URLByDeletingLastPathComponent?
      .URLByAppendingPathComponent("SyncHistoryStore")
      .URLByAppendingPathExtension("realm")
      .path
    
    self.config = config
  }
  
  public func verifyUpdating(records: [AddressBookRecord]) {
    guard let realm = realmInstance() else { return }
    
    let verifiedAt = NSDate().timeIntervalSince1970
    
    try! realm.write {
      records.forEach { record in
        guard let hashCode = record.hashCode() else { return }
        
        if let status = AddressBookRecordStatus.find(realm, recordId: record.id) {
          status.verifiedAt = verifiedAt
          status.deleted = false
          
          if status.isChanged(record) {
            status.hashCode = hashCode
            status.updatedAt = verifiedAt
          }
          
          return
        }
        
        let status = AddressBookRecordStatus()
        status.recordId = record.id
        status.deleted = false
        status.hashCode = hashCode
        status.verifiedAt = verifiedAt
        status.updatedAt = verifiedAt
        status.syncedAt = verifiedAt
        
        realm.add(status)
      }
    }
    
    AddressBookRecordStatus.markAsDelete(realm, timestamp: verifiedAt)
  }
  
  public func extractNeedSyncRecords(records: [AddressBookRecord]) -> [AddressBookRecord] {
    guard let realm = realmInstance() else { return [] }

    let recordIds = AddressBookRecordStatus.needSyncRecordIds(realm)
    return records.filter { recordIds.contains($0.id) }
  }
  
  public func markAsSynced(records: [AddressBookRecord]) {
    guard let realm = realmInstance() else { return }
    
    AddressBookRecordStatus.markAsSynced(realm, recordIds: records.map { $0.id }, timestamp: NSDate().timeIntervalSince1970)
  }
  
  public func clear() {
    guard let realm = realmInstance() else { return }

    try! realm.write {
      realm.deleteAll()
    }
  }
  
  public func realmInstance() -> Realm? {
    return try? Realm(configuration: config)
  }
}
