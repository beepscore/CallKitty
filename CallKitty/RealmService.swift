//
//  RealmService.swift
//  CallKitty
//
//  Created by Steve Baker on 11/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation
import RealmSwift
// import for UIViewController
import UIKit

class RealmService {

    // enforce singleton
    private init() {}

    static let shared = RealmService()

    // default realm is a file in app documents directory
    var realm = try! Realm()

    static let realmErrorNotificationName = NSNotification.Name("RealmError")

    // TODO: add/revise methods to use object with primary key?
    // Update 'object' if it already exists, add it if not.
    // https://academy.realm.io/posts/realm-primary-keys-tutorial/

    /// generic function to add an object to a realm
    /// - Parameter object: a generic type that subclasses Realm class Object
    func add<T: Object>(_ object: T) {
        do {
            try realm.write() {
                realm.add(object)
            }
        } catch {
            post(error)
        }
    }

    // tutorial author prefers to not wrap read()

    /// generic function to update an object
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
            post(error)
        }
    }

    func delete<T: Object>(_ object: T) {
        do {
            try realm.write() {
                realm.delete(object)
            }
        } catch {
            post(error)
        }
    }

    /// Note this method queries realm database, not call directory
    /// If call directory has not been synced to realm, returned result could be misleading
    /// - Returns: count of phoneCallers with shouldBlock true
    func blockedCount() -> Int {
        let filterString = PhoneCaller.PropertyStrings.shouldBlock.rawValue + " = true"
        let results = realm.objects(PhoneCaller.self).filter(filterString)
        return results.count
    }

    /// Note this method queries realm database, not call directory
    /// If call directory has not been synced to realm, returned result could be misleading
    /// - Returns: count of phoneCallers with label not equal to placeholder (empty string)
    func identifiedCount() -> Int {
        // e.g. "label != ''"
        let filterString = PhoneCaller.PropertyStrings.label.rawValue
            + " != '" + PhoneCaller.labelPlaceholder + "'"
        let results = realm.objects(PhoneCaller.self).filter(filterString)
        return results.count
    }

    // MARK: - notifications

    /// post error to notification center
    func post(_ error: Error) {
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
