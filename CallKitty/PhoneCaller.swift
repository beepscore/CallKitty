//
//  PhoneCaller.swift
//  CallKitty
//
//  Created by Steve Baker on 11/6/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//
// Abstract:
// Model class representing a phone caller

import Foundation
import CallKit
import RealmSwift

// Object is a Realm class
class PhoneCaller: Object {

    // use enum to reduce risk of misspelling a "stringly typed" key
    // https://spin.atomicobject.com/2016/08/04/swift-enums-hard-coded-strings/
    enum PropertyStrings: String {
        case phoneNumber = "phoneNumber"
        case label = "label"
        case shouldBlock = "shouldBlock"
        case shouldIdentify = "shouldIdentify"
    }

    static let phoneNumberPlaceholder: CXCallDirectoryPhoneNumber = -1
    static let labelPlaceholder = ""

    /// objects must be available at runtime, so generally set default value
    /// Most world phone numbers are <= 15 digits, CXCallDirectoryPhoneNumber must be big enough to hold a phone number.
    /// CXCallDirectoryPhoneNumber is an alias for Int64.
    /// 2^64 ~ 10^19, so Int64 can hold ~ 19 decimal digits without overflow.
    /// http://www.itu.int/ITU-T/recommendations/rec.aspx?rec=E.164
    /// https://stackoverflow.com/questions/723587/whats-the-longest-possible-worldwide-phone-number-i-should-consider-in-sql-varc#4729239
    @objc dynamic var phoneNumber: CXCallDirectoryPhoneNumber = phoneNumberPlaceholder

    // primaryKey enforces phoneNumber is unique
    // example query
    //    let specificPerson = realm.object(ofType: Person.self, forPrimaryKey: myPrimaryKey)
    // https://academy.realm.io/posts/realm-primary-keys-tutorial/
    override static func primaryKey() -> String? {
        return PropertyStrings.phoneNumber.rawValue
    }

    /// used for caller identification entry, not required for blocking entry
    /// phoneNumber won't be identified unless it is added to call directory as an identificationEntry
    @objc dynamic var label: String = labelPlaceholder

    // MARK: - flags for communication with CallKit CallDirectoryHandler: CXCallDirectoryProvider

    /// set true to indicate CallDirectoryHandler should update CallKit blocking and/or identifying directories for this PhoneCaller phoneNumber.
    /// default for a new PhoneCaller is true.
    /// After CallDirectoryHandler updates the directory entries, it can clear the flag
    /// This dedicated flag seems simpler and more reliable than attempting to compute a property based on
    /// potentially multiple changes to shouldBlock, shouldIdentify, shouldDelete, label.
    @objc dynamic var hasChanges: Bool = true

    /// set true to indicate CallDirectoryHandler should update CallKit blocking directory for this PhoneCaller phoneNumber.
    /// phoneNumber won't be blocked unless it is added to call directory as a blockingEntry
    @objc dynamic var shouldBlock: Bool = false

    /// set true to indicate CallKit is blocking calls from this PhoneCaller's phoneNumber.
    /// After CallDirectoryHandler adds or removes the number from the blocking directory, it can update this flag appropriately
    @objc dynamic var isBlocked: Bool = false

    /// set true to indicate CallDirectoryHandler should update CallKit identifying directory for this PhoneCaller phoneNumber.
    /// phoneNumber won't be identified unless it is added to call directory as an identifyingEntry
    /// After CallDirectoryHandler adds or removes the number from the identifying directory, it can update this flag appropriately
    @objc dynamic var shouldIdentify: Bool = false

    /// set true to indicate CallKit is identifying calls from this PhoneCaller's phoneNumber.
    /// After CallDirectoryHandler updates the identifiying directory entry, it can set the flag true
    @objc dynamic var isIdentified: Bool = false

    /// set true to indicate CallDirectoryHandler should delete any CallKit blocking and/or identifying entries for this PhoneCaller phoneNumber.
    /// After CallDirectoryHandler deletes the directory entries, it can delete this PhoneCaller object
    @objc dynamic var shouldDelete: Bool = false

    // MARK: -

    /// convenience initializer
    ///
    /// for additional parameter documentation see property declarations
    /// - Parameters:
    ///   - phoneNumber: a phone number, can be used to identify and/or block phone calls
    ///   - label: used to identify a caller. default is labelPlaceholder, e.g. empty string
    ///     Note non-empty label doesn't automatically set shouldIdentify true
    ///   - shouldBlock: set true to block calls from phoneNumber. default is false
    convenience init(phoneNumber: CXCallDirectoryPhoneNumber,
                     label: String = labelPlaceholder,
                     hasChanges: Bool = true,
                     shouldBlock: Bool = false,
                     isBlocked: Bool = false,
                     shouldIdentify: Bool = false,
                     isIdentified: Bool = false,
                     shouldDelete: Bool = false) {
        // must call designated initializer
        self.init()
        
        self.phoneNumber = phoneNumber
        self.label = label
        self.hasChanges = hasChanges
        self.shouldBlock = shouldBlock
        self.isBlocked = isBlocked
        self.shouldIdentify = shouldIdentify
        self.isIdentified = isIdentified
        self.shouldDelete = shouldDelete
    }

}
