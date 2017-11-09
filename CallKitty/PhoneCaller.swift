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

    // objects must be available at runtime, so generally set default value
    @objc dynamic var phoneNumberString: String = ""

    // optional String, used for blocking entry
    @objc dynamic var label: String? = nil

    // convenience initializer
    convenience init(phoneNumberString: String, label: String?) {
        // must call designated initializer
        self.init()

        self.phoneNumberString = phoneNumberString
        self.label = label
    }

}
