//
//  PhoneCallerTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
// import CallKit for CXCallDirectoryPhoneNumber
import CallKit
@testable import CallKitty

class PhoneCallerTests: XCTestCase {

    func testPhoneNumberPlaceholder() {
        XCTAssertEqual(-1, PhoneCaller.phoneNumberPlaceholder)
    }

    func testLabelPlaceholder() {
        XCTAssertEqual("", PhoneCaller.labelPlaceholder)
    }

    func testConvenienceInit() {

        let phoneNumber: CXCallDirectoryPhoneNumber = 1234567890
        let label = "foo"

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, label: label)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, label)
    }

    func testConvenienceInitLabelDefault() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 802_745_6859

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, PhoneCaller.labelPlaceholder)
    }

    func testConvenienceInitLabelEmptyString() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 01_802_745_6859
        let label = ""

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, label: label)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, label)
    }

    func testConvenienceInitPhoneNumberMaximumValueWith15DigitsDoesntRollOver() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 99999_99999_99999

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, PhoneCaller.labelPlaceholder)
    }
    
}
