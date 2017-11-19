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

    // TODO: Consider generate all phone numbers as US typical with length 7, 10, 11 digits and valid US area codes.
    // TODO: consider using Formatter, ValueTransformer or NSDataDetector to validate world phone numbers
    /// - returns: phone number as US typical with length 11 digits starting with country code 1
    /// Several web posts recommend make all CallKit phone numbers same length, at least for beta versions of CallKit
    /// https://forums.developer.apple.com/thread/51155
    /// http://iphoneramble.blogspot.com/2017/05/ios-10-callkit-directory-extension.html
    /// Most world phone numbers are <= 15 digits
    /// https://stackoverflow.com/questions/723587/whats-the-longest-possible-worldwide-phone-number-i-should-consider-in-sql-varc#4729239
    /// http://www.itu.int/ITU-T/recommendations/rec.aspx?rec=E.164
    /// to simplify generating large numbers > Int32.max,
    /// concatenate string then convert to CXCallDirectoryPhoneNumber (alias for Int64)
    func nextRandomPhoneNumber() -> CXCallDirectoryPhoneNumber {
        let numberOfDigitsAfterAreaCode = 7
        let digitString = nextRandomCountryCodeString()
            + nextRandomAreaCodeString()
            + nextRandomDigitString(numberOfDigits: numberOfDigitsAfterAreaCode)

        return CXCallDirectoryPhoneNumber(digitString)!
    }

    /// - returns: "1" to simplify initial debugging
    func nextRandomCountryCodeString() -> String {
        return "1"
    }

    // TODO: Consider return only valid US (or world?) area codes.
    // https://en.wikipedia.org/wiki/List_of_North_American_Numbering_Plan_area_codes
    /// - returns: "555" to simplify initial debugging
    func nextRandomAreaCodeString() -> String {
        return "555"
    }

    /// - returns: String to avoid losing digits from any leading zeroes
    func nextRandomDigitString(numberOfDigits: Int) -> String {
        var digitString = ""
        for _ in 0..<numberOfDigits {
            digitString = digitString + nextRandomDigitString()
        }
        return digitString
    }

    /// - returns: string from the next random digit from a random uniform distribution of integers
    func nextRandomDigitString() -> String {
        let nextInt = randomDistribution10.nextInt()
        return String(nextInt)
    }

    /// a random uniform distribution of integers
    /// randomDistribution.nextInt() returns the next random integer
    let randomDistribution10 = GKRandomDistribution(randomSource: GKARC4RandomSource(),
                                                    lowestValue: 0,
                                                    highestValue: 9)

}
