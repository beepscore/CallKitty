//
//  PhoneNumberFormatter.swift
//  CallKitty
//
//  Created by Steve Baker on 11/6/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//
// Abstract:
// Model class representing a phone caller

import Foundation
import CallKit

class PhoneNumberFormatter {

    // CXCallDirectoryPhoneNumber is type alias for Int64
    class func phoneNumber(phoneNumberString: String?) -> CXCallDirectoryPhoneNumber? {

        guard let sanitized = PhoneNumberFormatter.sanitizedPhoneNumberString(phoneNumberString: phoneNumberString) else { return nil }

        return CXCallDirectoryPhoneNumber(sanitized)
    }

    // TODO: consider using Formatter, ValueTransformer or NSDataDetector to validate world phone numbers
    // Deletes characters that aren't decimal digits, trims to max length 14 digits
    class func sanitizedPhoneNumberString(phoneNumberString: String?) -> String? {

        guard let phoneNumberString = phoneNumberString else { return nil }

        let phoneNumberDigits = String(phoneNumberString.filter { String($0).rangeOfCharacter(from: CharacterSet.decimalDigits) != nil })
        let digitsMax = 14
        let phoneNumberDigitsPrefix = String(phoneNumberDigits.prefix(digitsMax))
        return phoneNumberDigitsPrefix
    }

}
