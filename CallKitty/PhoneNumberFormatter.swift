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
    /// GameKit GKRandomDistribution returns Int, might be 32 bit or 64 bit depending upon machine
    /// Assume test will run on 64 bit macOS or iPhone
    /// https://developer.apple.com/library/tvos/documentation/GameplayKit/Reference/GKShuffledDistribution_Class/index.html
    /// https://stackoverflow.com/questions/24007129/how-does-one-generate-a-random-number-in-apples-swift-language#24098445
    /// setting highestValue to Int.max didn't work. Int.max -1 seems to work.
    let randomDistribution = GKRandomDistribution(randomSource: GKARC4RandomSource(),
                                                  lowestValue: 0,
                                                  highestValue: Int.max - 1)

     /// - returns: the next random integer from a random uniform distribution of integers
    func nextRandomPhoneNumber() -> CXCallDirectoryPhoneNumber {
        let nextInt = randomDistribution.nextInt()
        return CXCallDirectoryPhoneNumber(nextInt)
    }

}
