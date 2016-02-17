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
  
  public func verifyUpdating(records: [AddressBookRecord]) {
    let realm = ABSRealm.instance()
    
    let verifiedAt = NSDate().timeIntervalSince1970
    
    try! realm.write {
      records.forEach { record in
        guard let hashCode = record.hashCode() else { return }
        
        if let status = AddressBookRecordStatus.find(record.id) {
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
      
      AddressBookRecordStatus.markAsDelete(verifiedAt)
    }
  }
  
  public func extractNeedSyncRecords(records: [AddressBookRecord]) -> [AddressBookRecord] {
    let recordIds = AddressBookRecordStatus.needSyncRecordIds()
    return records.filter { recordIds.contains($0.id) }
  }

  public func fetchAllDeletedRecordIds() -> [String] {
    return AddressBookRecordStatus.fetchAllDeletedRecordIds()
  }
  
  public func markAsSynced(records: [AddressBookRecord]) {
    try! ABSRealm.instance().write {
      AddressBookRecordStatus.markAsSynced(records.map { $0.id }, timestamp: NSDate().timeIntervalSince1970)
    }
  }
  
  public func destoryAllDeletedRecords(recordIds: [String]) {
    try! ABSRealm.instance().write {
      AddressBookRecordStatus.destoryAllDeletedRecords(recordIds)
    }
  }
  
  public func clear() {
    let realm = ABSRealm.instance()
    try! realm.write {
      realm.deleteAll()
    }
  }
}
