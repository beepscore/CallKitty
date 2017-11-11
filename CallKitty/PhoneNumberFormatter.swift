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
import GameKit

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

    /// a random uniform distribution of integers
    /// randomDistribution.nextInt() returns the next random integer
    let randomDistribution1000 = GKRandomDistribution(randomSource: GKARC4RandomSource(),
                                                  lowestValue: 0,
                                                  highestValue: 1000)

    /// - returns: the next random integer from a random uniform distribution of integers
    func nextRandomThousand() -> CXCallDirectoryPhoneNumber {
        let nextInt = randomDistribution1000.nextInt()
        return CXCallDirectoryPhoneNumber(nextInt)
    }

    /// to simplify generating large numbers > Int32.max,
    /// concatenate string then convert to CXCallDirectoryPhoneNumber (alias for Int64)
    func nextRandomPhoneNumber() -> CXCallDirectoryPhoneNumber {
        let numberOfDecimalDigits = 15
        let numberOfGroupsOf3 = numberOfDecimalDigits / 3
        var digitString = ""
        for _ in 0..<numberOfGroupsOf3 {
            let nextThousand = nextRandomThousand()
            digitString = digitString + String(nextThousand)
        }
        return CXCallDirectoryPhoneNumber(digitString)!
    }

}
