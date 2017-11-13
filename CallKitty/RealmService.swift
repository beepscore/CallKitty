//
//  RealmService.swift
//  CallKitty
//
//  Created by Steve Baker on 11/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation
import RealmSwift
// import CallKit for CXCallDirectoryPhoneNumber
import CallKit
// import UIKit for UIViewController
import UIKit

class RealmService {

    // enforce singleton
    private init() {}

    static let shared = RealmService()

    // default realm is a file in app documents directory
    var realm = try! Realm()

    static let realmErrorNotificationName = NSNotification.Name("RealmError")

    // TODO: make background versions for more methods, for use with large or remote data
    // e.g. similar to backgroundAddBlockingPhoneCallers

    // MARK: - PhoneCaller specific methods, use primary key phoneNumber

    /// If phoneCaller for unique primary key PhoneNumber already exists, update it.
    /// If phoneCaller doesn't already exist, add it with supplied properties
    /// for additional parameter documentation see PhoneCaller
    /// https://academy.realm.io/posts/realm-primary-keys-tutorial/
    ///
    /// - Parameters:
    ///   - phoneNumber: a CallKit CXCallDirectoryPhoneNumber, unique primary key
    ///   - label: label for new PhoneCaller
    ///   - realm: Realm context
    static func addUpdatePhoneCaller(phoneNumber: CXCallDirectoryPhoneNumber,
                                     label: String = PhoneCaller.labelPlaceholder,
                                     hasChanges: Bool = true,
                                     shouldBlock: Bool = false,
                                     isBlocked: Bool = false,
                                     shouldIdentify: Bool = false,
                                     isIdentified: Bool = false,
                                     shouldDelete: Bool = false,
                                     realm: Realm) {
        do {
            try realm.write() {
                var phoneCaller: PhoneCaller

                let fetchedPhoneCaller = getPhoneCaller(phoneNumber: phoneNumber, realm: realm)

                if fetchedPhoneCaller != nil {
                    phoneCaller = fetchedPhoneCaller!
                } else {
                    // new phone caller with default properties
                    phoneCaller = PhoneCaller(phoneNumber: phoneNumber)
                }

                // set realm object properties within a write() block
                phoneCaller.label = label
                phoneCaller.hasChanges = hasChanges
                phoneCaller.shouldBlock = shouldBlock
                phoneCaller.isBlocked = isBlocked
                phoneCaller.shouldIdentify = shouldIdentify
                phoneCaller.isIdentified = isIdentified
                phoneCaller.shouldDelete = shouldDelete

                realm.add(phoneCaller, update: true)
            }
        } catch {
            RealmService.post(error)
        }
    }

    /// Add blocking callers on a background thread. Interested objects can observe realm for changes/completion
    /// - Parameters:
    ///   - count: approximate number of PhoneCallers to add.
    ///   If random generates a duplicate phoneNumber, it will update previous entry
    ///   and number will be less than count
    static func backgroundAddBlockingPhoneCallers(count: Int) {
        DispatchQueue.global().async {
            // Get new realm and table since we are in a new thread.

            // Realm instances are not thread safe and cannot be shared across threads or dispatch queues.
            // You must construct a new instance for each thread in which a Realm will be accessed.
            // For dispatch queues, this means that you must construct a new instance
            // in each block which is dispatched, as a queue is not guaranteed to run all of its blocks on the same thread.
            // https://realm.io/docs/swift/latest/api/Classes/Realm.html#/s:FC10RealmSwift5Realm3addFTCS_6Object6updateSb_T_
            let realm = try! Realm()
            RealmService.addBlockingPhoneCallers(count: count, realm: realm)
        }
    }
    
    /// - Parameters:
    ///   - count: approximate number of PhoneCallers to add.
    ///   If random generates a duplicate phoneNumber, it will update previous entry
    ///   and number will be less than count
    ///   - realm: Realm context
    static func addBlockingPhoneCallers(count: Int, realm: Realm) {
        do {
            let phoneNumberFormatter = PhoneNumberFormatter()

            try realm.write() {

                // for efficiency, "batch" loop inside a single write
                for _ in 0..<count {

                    let phoneNumber = phoneNumberFormatter.nextRandomPhoneNumber()

                    var phoneCaller: PhoneCaller
                    let fetchedPhoneCaller = getPhoneCaller(phoneNumber: phoneNumber, realm: realm)

                    if fetchedPhoneCaller != nil {
                        phoneCaller = fetchedPhoneCaller!
                        phoneCaller.label = "dog"
                        phoneCaller.shouldBlock = true

                    } else {
                        phoneCaller = PhoneCaller(phoneNumber: phoneNumber,
                                                  label: "dog",
                                                  shouldBlock: true)
                    }
                    realm.add(phoneCaller, update: true)
                }
            }
        } catch {
            RealmService.post(error)
        }
    }

    /// Gets specified PhoneCaller via unique primary key phoneNumber
    /// - Parameter phoneNumber: a CallKit CXCallDirectoryPhoneNumber
    /// - Returns: phoneCaller or nil
    static func getPhoneCaller(phoneNumber: CXCallDirectoryPhoneNumber, realm: Realm) -> PhoneCaller? {
        let phoneCaller = realm.object(ofType: PhoneCaller.self,
                                       forPrimaryKey: phoneNumber)
        return phoneCaller
    }

    /// Gets all PhoneCallers
    /// - Returns: realm Result of phoneCallers
    static func getAllPhoneCallers(realm: Realm) -> Results<PhoneCaller> {
        let phoneCallers = realm.objects(PhoneCaller.self)
            .sorted(byKeyPath: PhoneCaller.PropertyStrings.phoneNumber.rawValue)
        return phoneCallers
    }

    // MARK: - shouldBlock

    /// - Returns: realm Result of all phoneCallers with shouldBlock true, sorted by phone number
    static func getAllPhoneCallersShouldBlockSorted(realm: Realm) -> Results<PhoneCaller> {
        let filterString = PhoneCaller.PropertyStrings.shouldBlock.rawValue + " = true"
        let allPhoneCallersBlockedSorted = realm.objects(PhoneCaller.self).filter(filterString)
            .sorted(byKeyPath: PhoneCaller.PropertyStrings.phoneNumber.rawValue)
        return allPhoneCallersBlockedSorted
    }

    /// Note this method queries realm database, not call directory
    /// If call directory has not been synced to realm, returned result could be misleading
    /// - Returns: count of phoneCallers with shouldBlock true
    static func getAllPhoneCallersShouldBlockSortedCount(realm: Realm) -> Int {
        let allPhoneCallersBlockedSorted = RealmService.getAllPhoneCallersShouldBlockSorted(realm: realm)
        return allPhoneCallersBlockedSorted.count
    }

    /// - Returns: array of all phone numbers with shouldBlock true,
    /// sorted by phone number as required by CallKit call directory addBlockingEntry
    static func getAllPhoneNumbersShouldBlockSorted(realm: Realm) -> [CXCallDirectoryPhoneNumber] {
        let allPhoneCallersShouldBlockSorted = RealmService.getAllPhoneCallersShouldBlockSorted(realm: realm)

        // type is Realm LazyMapRandomAccessCollection
        // TODO: see if can return LazyMapRandomAccessCollection instead
        let allPhoneNumbersShouldBlockSorted = allPhoneCallersShouldBlockSorted.map { phoneCaller in phoneCaller.phoneNumber }

        let allPhoneNumbersShouldBlockSortedArray = Array(allPhoneNumbersShouldBlockSorted)
        return allPhoneNumbersShouldBlockSortedArray
    }

    // MARK: - identified

    /// Gets all PhoneCallers with label not empty string
    /// - Returns: phoneCallers with label not equal to placeholder (empty string)
    static func getAllPhoneCallersIdentifiedSorted(realm: Realm) -> Results<PhoneCaller> {
        // e.g. "label != ''"
        let filterString = PhoneCaller.PropertyStrings.label.rawValue
            + " != '" + PhoneCaller.labelPlaceholder + "'"
        let allPhoneCallersIdentifiedSorted = realm.objects(PhoneCaller.self).filter(filterString)
            .sorted(byKeyPath: PhoneCaller.PropertyStrings.phoneNumber.rawValue)
        return allPhoneCallersIdentifiedSorted
    }

    /// Note this method queries realm database, not call directory
    /// If call directory has not been synced to realm, returned result could be misleading
    /// - Returns: count of identified phoneCallers
    static func getAllPhoneCallersIdentifiedSortedCount(realm: Realm) -> Int {
        let allPhoneCallersIdentifiedSorted = RealmService.getAllPhoneCallersIdentifiedSorted(realm: realm)
        return allPhoneCallersIdentifiedSorted.count
    }

    /// - Returns: array of all identified phone numbers,
    /// sorted by phone number as required by CallKit call directory addBlockingEntry
    static func getAllPhoneNumbersIdentifiedSorted(realm: Realm) -> [CXCallDirectoryPhoneNumber] {
        let allPhoneCallersIdentifiedSorted = RealmService.getAllPhoneCallersIdentifiedSorted(realm: realm)

        // type is Realm LazyMapRandomAccessCollection
        // TODO: see if can return LazyMapRandomAccessCollection instead
        let allPhoneNumbersIdentifiedSorted = allPhoneCallersIdentifiedSorted.map { phoneCaller in phoneCaller.phoneNumber }

        let allPhoneNumbersIdentifiedSortedArray = Array(allPhoneNumbersIdentifiedSorted)
        return allPhoneNumbersIdentifiedSortedArray
    }

    // MARK: - delete

    /// Deletes phoneCaller in background if caller with phoneNumber exists.
    /// Method is "safe", doesn't error if phoneCaller doesn't exist.
    /// - Parameter phoneNumber: a CallKit CXCallDirectoryPhoneNumber
    static func backgroundDeletePhoneCaller(phoneNumber: CXCallDirectoryPhoneNumber) {
        DispatchQueue.global().async {
            let realm = try! Realm()
            let _ = RealmService.deletePhoneCaller(phoneNumber: phoneNumber, realm: realm)
        }
    }

    /// Deletes phoneCaller if caller with phoneNumber exists.
    /// Method is "safe", doesn't error if phoneCaller doesn't exist.
    /// - Parameter phoneNumber: a CallKit CXCallDirectoryPhoneNumber
    /// - Returns: deleted phoneCaller (might be invalid after delete).
    /// returns nil if not found
    static func deletePhoneCaller(phoneNumber: CXCallDirectoryPhoneNumber, realm: Realm) -> PhoneCaller? {
        guard let phoneCaller = getPhoneCaller(phoneNumber: phoneNumber, realm: realm) else { return nil }
        do {
            try realm.write() {
                realm.delete(phoneCaller)
            }
        } catch {
            RealmService.post(error)
        }
        return phoneCaller
    }

    /// Delete all objects
    /// https://stackoverflow.com/questions/26185679/how-can-i-easily-delete-all-objects-in-a-realm
    static func backgroundDeleteAllObjects() {
        DispatchQueue.global().async {
            // Get new realm and table since we are in a new thread.

            // Realm instances are not thread safe and cannot be shared across threads or dispatch queues.
            // You must construct a new instance for each thread in which a Realm will be accessed.
            // For dispatch queues, this means that you must construct a new instance
            // in each block which is dispatched, as a queue is not guaranteed to run all of its blocks on the same thread.
            // https://realm.io/docs/swift/latest/api/Classes/Realm.html#/s:FC10RealmSwift5Realm3addFTCS_6Object6updateSb_T_
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
        }
    }

    // MARK: - generic functions

    /// generic function to add an object to a realm
    /// Caution: if object with this primary key exists, throws error.
    /// For object of type PhoneCaller, generally prefer method addUpdatePhoneCaller()
    /// - Parameter object: a generic type that subclasses Realm class Object
    func add<T: Object>(_ object: T) {
        do {
            try realm.write() {
                realm.add(object)
            }
        } catch {
            RealmService.post(error)
        }
    }

    /// generic function to update an object
    /// For object of type PhoneCaller, generally prefer method addUpdatePhoneCaller()
    ///
    /// - Parameters:
    ///   - object: object to update
    ///   - dictionary: contains keys corresponding to object properties
    func update<T: Object>(_ object: T, with dictionary: [String: Any?]) {
        do {
            // for improved performance when doing multiple changes,
            // call write once and "batch" any changes inside it.
            try realm.write() {
                for (key, value) in dictionary {
                    // setValue is compatible with a generic object, sets property named "key" to value
                    // syntax object.key = value won't work
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            RealmService.post(error)
        }
    }

    func delete<T: Object>(_ object: T) {
        do {
            try realm.write() {
                realm.delete(object)
            }
        } catch {
            RealmService.post(error)
        }
    }

    // MARK: - notifications

    /// post error to notification center
    static func post(_ error: Error) {
        // post on main queue to avoid potential crash in observers like view controllers.
        // Can specify queue in addObserver or in post, either one should suffice.
        // Do it both places for "belt and suspenders" goof proofing.
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: RealmService.realmErrorNotificationName,
                                            object: error)
        }
    }

    // TODO: check this tutorial code. addObserverRealmError seems to not use vc.
    // Use addObserver(_:selector:name:object:) instead?
    // Does it work together with realm.observe()??
    // e.g. notificationToken = realm.observe({ (notification, realm) in self.TableView.reloadData() })

    /// caller observers can react as they like e.g. show an alert
    ///
    /// - Parameters:
    ///   - vc: view controller, not used??
    ///   - completion: block to be executed when notification is received
    func addObserverRealmError(in vc: UIViewController, completion: @escaping (Error?) -> Void) {
        // object is object that posted the notification
        // last argument "using:" is a completion block containing the notification
        // returns an "opaque object" to act as the observer

        // tutorial code is not keeping a reference to returned value for use in remove observer.
        // Specify main queue to ensure completion is not run in a background queue.
        // This avoids potential crash in observers like view controllers.
        // https://stackoverflow.com/questions/15813764/posting-nsnotification-on-the-main-thread/42800900#42800900
        let _ = NotificationCenter.default.addObserver(forName: RealmService.realmErrorNotificationName,
                                                       object: nil,
                                                       queue: OperationQueue.main) { (notification) in
                                                        completion(notification.object as? Error)
        }
    }

    func removeObserverRealmError(in vc: UIViewController) {
        // last argument is a completion block
        // tutorial doesn't specify an observer, so all observers will be removed?
        NotificationCenter.default.removeObserver(vc,
                                                  name: RealmService.realmErrorNotificationName,
                                                  object: nil)
    }

}
