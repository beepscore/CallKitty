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

    // MARK: - PhoneCaller specific methods, use primary key phoneNumber

    /// If phoneCaller for unique primary key PhoneNumber already exists, update it.
    /// If phoneCaller doesn't already exist, add it with supplied properties
    /// https://academy.realm.io/posts/realm-primary-keys-tutorial/
    ///
    /// - Parameters:
    ///   - phoneNumber: a CallKit CXCallDirectoryPhoneNumber, unique primary key
    ///   - label: label for new PhoneCaller
    ///   - shouldBlock: shouldBlock for new PhoneCaller
    ///   - realm: Realm context
    static func addUpdatePhoneCaller(phoneNumber: CXCallDirectoryPhoneNumber,
                                     label: String = PhoneCaller.labelPlaceholder,
                                     shouldBlock: Bool = false,
                                     realm: Realm) {
        do {
            try realm.write() {
                var phoneCaller: PhoneCaller
                let fetchedPhoneCaller = getPhoneCaller(phoneNumber: phoneNumber, realm: realm)

                if fetchedPhoneCaller != nil {
                    phoneCaller = fetchedPhoneCaller!
                    phoneCaller.label = label
                    phoneCaller.shouldBlock = shouldBlock

                } else {
                    phoneCaller = PhoneCaller(phoneNumber: phoneNumber,
                                              label: label,
                                              shouldBlock: shouldBlock)
                }
                realm.add(phoneCaller, update: true)
            }
        } catch {
            RealmService.post(error)
        }
    }

    // TODO: consider do this on a background thread and observe for completion
    
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

    /// Deletes phone number if it exists.
    /// - Parameter phoneNumber: a CallKit CXCallDirectoryPhoneNumber
    /// - Returns: deleted phoneCaller. returns nil if not found
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

    /// Note this method queries realm database, not call directory
    /// If call directory has not been synced to realm, returned result could be misleading
    /// - Returns: count of phoneCallers with shouldBlock true
    static func blockedCount(realm: Realm) -> Int {
        let filterString = PhoneCaller.PropertyStrings.shouldBlock.rawValue + " = true"
        let results = realm.objects(PhoneCaller.self).filter(filterString)
        return results.count
    }

    /// Note this method queries realm database, not call directory
    /// If call directory has not been synced to realm, returned result could be misleading
    /// - Returns: count of phoneCallers with label not equal to placeholder (empty string)
    static func identifiedCount(realm: Realm) -> Int {
        // e.g. "label != ''"
        let filterString = PhoneCaller.PropertyStrings.label.rawValue
            + " != '" + PhoneCaller.labelPlaceholder + "'"
        let results = realm.objects(PhoneCaller.self).filter(filterString)
        return results.count
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
