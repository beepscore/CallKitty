//
//  CallDirectoryHandler.swift
//  CallKittyDirectoryExtension
//
//  Created by Steve Baker on 11/7/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation
import CallKit
import RealmSwift

class CallDirectoryHandler: CXCallDirectoryProvider {

    let realmService = RealmService.shared

    // MARK: -

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        // used during development to clear a call directory
        // removeAllBlockingAndIdentificationEntries(with: context)

        // Check whether this is an "incremental" data request. If so, only provide the set of phone number blocking
        // and identification entries which have been added or removed since the last time this extension's data was loaded.
        // But the extension must still be prepared to provide the full set of data at any time, so add all blocking
        // and identification phone numbers if the request is not incremental.
        if context.isIncremental {
            // Calling removeBlockingEntryWithPhoneNumber: when isIncremental is false is unsupported
            deleteAllShouldDelete(context: context)

            addOrRemoveIncrementalBlockingPhoneNumbers(to: context)

            addOrRemoveIncrementalIdentificationPhoneNumbers(to: context)
        } else {
            addAllBlockingPhoneNumbers(to: context)

            addAllIdentificationPhoneNumbers(to: context)
        }

        context.completeRequest()
    }

    /// used during development to clear a call directory
    /// typically run infrequently and then commented out
    func removeAllBlockingAndIdentificationEntries(with context: CXCallDirectoryExtensionContext) {
        context.removeAllBlockingEntries()
        context.removeAllIdentificationEntries()
        print("removeAllBlockingAndIdentificationEntries")
    }

    func deleteAllShouldDelete(context: CXCallDirectoryExtensionContext) {
        let phoneCallers = RealmService.getAllPhoneCallersShouldDeleteSorted(realm: realmService.realm)
        for phoneCaller in phoneCallers {
            context.removeBlockingEntry(withPhoneNumber: phoneCaller.phoneNumber)
            context.removeIdentificationEntry(withPhoneNumber: phoneCaller.phoneNumber)
            // TODO: backgroundDeletePhoneCaller threw error realm accessed from wrong thread
            let _ = RealmService.deletePhoneCaller(phoneNumber: phoneCaller.phoneNumber,
                                                   realm: realmService.realm)
        }
    }

    // MARK: - blocking

    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve all phone numbers to block from data store.
        // For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.

        // TODO: may need to check if ok to use background queue here
        DispatchQueue.global().async {

            let realm = try! Realm()

            let allPhoneCallersShouldBlockOrIsBlockedSorted: Results<PhoneCaller> = RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realm)

            for phoneCaller in allPhoneCallersShouldBlockOrIsBlockedSorted {

                // update call directory
                context.addBlockingEntry(withNextSequentialPhoneNumber: phoneCaller.phoneNumber)

                // update realm
                // writing to realm inside a loop is less efficient than a batched write,
                // but has less risk of the realm getting out of sync with call directory
                try! realm.write() {
                    phoneCaller.isBlocked = true
                    phoneCaller.shouldBlock = false

                    if phoneCaller.shouldBlock == false
                        && phoneCaller.shouldIdentify == false
                        && phoneCaller.shouldDelete == false {
                        phoneCaller.hasChanges = false
                    }
                }
            }
        }
    }

    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve any changes to the set of phone numbers to block from data store.
        // For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.

        // TODO: may need to check if ok to use background queue here
        DispatchQueue.global().async {

            let realm = try! Realm()

            // add
            let allPhoneCallersIncrementalAddBlockingSorted: Results<PhoneCaller> = RealmService.getAllPhoneCallersIncrementalAddBlockingSorted(realm: realm)
            for phoneCaller in allPhoneCallersIncrementalAddBlockingSorted {

                // update call directory
                context.addBlockingEntry(withNextSequentialPhoneNumber: phoneCaller.phoneNumber)

                // update realm
                // writing to realm inside a loop is less efficient than a batched write,
                // but has less risk of the realm getting out of sync with call directory
                try! realm.write() {
                    phoneCaller.isBlocked = true
                    phoneCaller.shouldBlock = false

                    if phoneCaller.shouldBlock == false
                        && phoneCaller.shouldIdentify == false
                        && phoneCaller.shouldDelete == false {
                        phoneCaller.hasChanges = false
                    }
                }
            }

            // remove
            let allPhoneCallersIncrementalRemoveBlockingSorted: Results<PhoneCaller> = RealmService.getAllPhoneCallersIncrementalRemoveBlockingSorted(realm: realm)
            for phoneCaller in allPhoneCallersIncrementalRemoveBlockingSorted {

                // update call directory
                context.removeBlockingEntry(withPhoneNumber: phoneCaller.phoneNumber)

                // update realm
                // writing to realm inside a loop is less efficient than a batched write,
                // but has less risk of the realm getting out of sync with call directory
                try! realm.write() {
                    phoneCaller.isBlocked = false
                    phoneCaller.shouldBlock = false
                    
                    if phoneCaller.shouldBlock == false
                        && phoneCaller.shouldIdentify == false
                        && phoneCaller.shouldDelete == false {
                        phoneCaller.hasChanges = false
                    }
                }
            }
        }
        // Record the most-recently loaded set of blocking entries in data store for the next incremental load...
    }

    // MARK: - caller identification

    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve phone numbers to identify and their identification labels from data store.
        // For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.

        // Numbers must be provided in numerically ascending order.

        // TODO: may need to check if ok to use background queue here
        DispatchQueue.global().async {

            let realm = try! Realm()

            let allPhoneCallersShouldIdentifyOrIsIdentifiedSorted: Results<PhoneCaller> = RealmService.getAllPhoneCallersShouldIdentifyOrIsIdentifiedSorted(realm: realm)

            for phoneCaller in allPhoneCallersShouldIdentifyOrIsIdentifiedSorted {

                // update call directory
                context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneCaller.phoneNumber,
                    label: phoneCaller.label)

                // update realm
                // writing to realm inside a loop is less efficient than a batched write,
                // but has less risk of the realm getting out of sync with call directory
                try! realm.write() {
                    phoneCaller.isIdentified = true
                    phoneCaller.shouldIdentify = false

                    if phoneCaller.shouldBlock == false
                    && phoneCaller.shouldIdentify == false
                    && phoneCaller.shouldDelete == false {
                        phoneCaller.hasChanges = false
                    }
                }
            }
        }
    }

    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve any changes to the set of phone numbers to identify (and their identification labels) from data store.
        // For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.

        // TODO: may need to check if ok to use background queue here
        DispatchQueue.global().async {

            let realm = try! Realm()

            // add
            let allPhoneCallersIncrementalAddIdentificationSorted: Results<PhoneCaller> = RealmService.getAllPhoneCallersIncrementalAddIdentificationSorted(realm: realm)
            for phoneCaller in allPhoneCallersIncrementalAddIdentificationSorted {

                // update call directory
                context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneCaller.phoneNumber,
                                               label: phoneCaller.label)

                // update realm
                // writing to realm inside a loop is less efficient than a batched write,
                // but has less risk of the realm getting out of sync with call directory
                try! realm.write() {
                    phoneCaller.isIdentified = true
                    phoneCaller.shouldIdentify = false

                    if phoneCaller.shouldBlock == false
                        && phoneCaller.shouldIdentify == false
                        && phoneCaller.shouldDelete == false {
                        phoneCaller.hasChanges = false
                    }
                }
            }

            // remove
            let allPhoneCallersIncrementalRemoveIdentificationSorted: Results<PhoneCaller> = RealmService.getAllPhoneCallersIncrementalRemoveIdentificationSorted(realm: realm)
            for phoneCaller in allPhoneCallersIncrementalRemoveIdentificationSorted {

                // update call directory
                context.removeIdentificationEntry(withPhoneNumber: phoneCaller.phoneNumber)

                // update realm
                // writing to realm inside a loop is less efficient than a batched write,
                // but has less risk of the realm getting out of sync with call directory
                try! realm.write() {
                    phoneCaller.isIdentified = false
                    phoneCaller.shouldIdentify = false

                    if phoneCaller.shouldBlock == false
                        && phoneCaller.shouldIdentify == false
                        && phoneCaller.shouldDelete == false {
                        phoneCaller.hasChanges = false
                    }
                }
            }
        }
        // Record the most-recently loaded set of identification entries in data store for the next incremental load...
    }

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.

        // TODO: consider if we want to pass error info to the containing app
        print("CallDirectoryHandler requestFailed", error.localizedDescription)
    }

}
