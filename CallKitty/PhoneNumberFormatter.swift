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

    // Deletes characters that aren't decimal digits, trims to max length 15 digits
    class func sanitizedPhoneNumberString(phoneNumberString: String?) -> String? {

        guard let phoneNumberString = phoneNumberString else { return nil }

        let phoneNumberDigits = String(phoneNumberString.filter { String($0).rangeOfCharacter(from: CharacterSet.decimalDigits) != nil })
        let digitsMax = 15
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

    // TODO: consider generate some phone numbers as US typical with length 7, 10, 11 digits and valid US area codes.
    // https://en.wikipedia.org/wiki/List_of_North_American_Numbering_Plan_area_codes

    // TODO: consider using Formatter, ValueTransformer or NSDataDetector to validate world phone numbers
    /// Most world phone numbers are <= 15 digits
    /// http://www.itu.int/ITU-T/recommendations/rec.aspx?rec=E.164
    /// to simplify generating large numbers > Int32.max,
    /// concatenate string then convert to CXCallDirectoryPhoneNumber (alias for Int64)
    func nextRandomPhoneNumber() -> CXCallDirectoryPhoneNumber {
        // https://stackoverflow.com/questions/723587/whats-the-longest-possible-worldwide-phone-number-i-should-consider-in-sql-varc#4729239
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
