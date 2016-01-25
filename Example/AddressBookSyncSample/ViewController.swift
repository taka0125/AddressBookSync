//
//  ViewController.swift
//  AddressBookSync
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import UIKit
import AddressBookSync

class ViewController: UIViewController {
  @IBAction func scan() {
    let status = AddressBook.sharedInstance.authorizationStatus()
    switch status {
    case .Authorized:
      fetchAll()
      return
    default:
      break
    }
    
    AddressBook.sharedInstance.requestAccess { [weak self] (granted, _) -> Void in
      if granted {
        self?.fetchAll()
      } else {
        print("Access denied")
      }
    }
  }
  
  @IBAction func sync() {
    let addressBookRecords = AddressBook.sharedInstance.fetchAll()
    print("===== all records =====")
    print(addressBookRecords.count)
    
    SyncHistory.sharedInstance.verifyUpdating(addressBookRecords)
    
    let deletedRecordIds = SyncHistory.sharedInstance.fetchAllDeletedRecordIds()
    print("===== deleted count =====")
    print(deletedRecordIds.count)
    
    let records = SyncHistory.sharedInstance.extractNeedSyncRecords(addressBookRecords)
    print("===== extracted count =====")
    print(records.count)
    
    SyncHistory.sharedInstance.markAsSynced(records)
    
    SyncHistory.sharedInstance.destoryAllDeletedRecords(deletedRecordIds)
  }
}

extension ViewController {
  private func fetchAll() {
    let addressBookRecords = AddressBook.sharedInstance.fetchAll()
    print(addressBookRecords)
  }
}
