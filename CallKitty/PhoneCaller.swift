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
    @objc dynamic var label: String = labelPlaceholder

    /// set true to block
    @objc dynamic var isBlocked: Bool = false

    /// convenience initializer
    ///
    /// - Parameters:
    ///   - phoneNumber: a phone number, can be used to identify and/or block phone calls
    ///   - label: used to identify a caller. default is labelPlaceholder, e.g. empty string
    ///   - isBlocked: set true to block calls from phoneNumber. default is false
    convenience init(phoneNumber: CXCallDirectoryPhoneNumber, label: String = labelPlaceholder, isBlocked: Bool = false) {
        // must call designated initializer
        self.init()

        self.phoneNumber = phoneNumber
        self.label = label
        self.isBlocked = isBlocked
    }

}
