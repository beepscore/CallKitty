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
    }

    static let phoneNumberPlaceholder: CXCallDirectoryPhoneNumber = -1
    static let labelPlaceholder = ""

    /// objects must be available at runtime, so generally set default value
    /// CXCallDirectoryPhoneNumber is an alias for Int64.
    /// 2^64 ~ 10^19, so this type can hold ~ 19 decimal digits without overflow.
    /// Most world phone numbers are <= 15 digits
    /// http://www.itu.int/ITU-T/recommendations/rec.aspx?rec=E.164
    /// https://stackoverflow.com/questions/723587/whats-the-longest-possible-worldwide-phone-number-i-should-consider-in-sql-varc#4729239
    @objc dynamic var phoneNumber: CXCallDirectoryPhoneNumber = phoneNumberPlaceholder

    /// used for caller identification entry, not required for blocking entry
    /// phoneNumber won't be identified unless it is added to call directory as an identificationEntry
    @objc dynamic var label: String = labelPlaceholder

    /// set true to indicate phone should block calls from phoneNumber.
    /// phoneNumber won't be blocked unless it is added to call directory as a blockingEntry
    @objc dynamic var shouldBlock: Bool = false

    /// convenience initializer
    ///
    /// - Parameters:
    ///   - phoneNumber: a phone number, can be used to identify and/or block phone calls
    ///   - label: used to identify a caller. default is labelPlaceholder, e.g. empty string
    ///   - shouldBlock: set true to block calls from phoneNumber. default is false
    convenience init(phoneNumber: CXCallDirectoryPhoneNumber, label: String = labelPlaceholder, shouldBlock: Bool = false) {
        // must call designated initializer
        self.init()

        self.phoneNumber = phoneNumber
        self.label = label
        self.shouldBlock = shouldBlock
    }

}
