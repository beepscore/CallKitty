//
//  PhoneNumberFormatterTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import CallKitty

class PhoneNumberFormatterTests: XCTestCase {

    // MARK: - test phoneNumber

    func testPhoneNumberNil() {
        XCTAssertNil(PhoneNumberFormatter.phoneNumber(phoneNumberString: nil))
    }

    func testPhoneNumberEmptyString() {
        XCTAssertNil(PhoneNumberFormatter.phoneNumber(phoneNumberString: ""))
    }

    func testPhoneNumberNoDigits() {
        XCTAssertNil(PhoneNumberFormatter.phoneNumber(phoneNumberString: "abcsdaffEEEBIAFBM DSF"))
    }

    func testPhoneNumberAllDigits() {
        let actual = PhoneNumberFormatter.phoneNumber(phoneNumberString: "12345678901234567890")
        XCTAssertEqual(actual, 12345678901234)
    }

    func testPhoneNumberMixedString() {
        let actual = PhoneNumberFormatter.phoneNumber(phoneNumberString: "abc123hij98(7)+")
        XCTAssertEqual(actual, 123987)
    }

    // MARK: - test sanitizedPhoneNumberString

    func testSanitizedPhoneNumberString() {
        let actual = PhoneNumberFormatter.sanitizedPhoneNumberString(phoneNumberString: "12345678901234567890")
        XCTAssertEqual(actual!.count, 14)
        XCTAssertEqual(actual, "12345678901234")
    }


}
