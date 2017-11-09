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
        let isBlocked = true

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, label: label, isBlocked: isBlocked)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, label)
        XCTAssertEqual(phoneCaller.isBlocked, isBlocked)
    }

    func testConvenienceInitLabelDefault() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 802_745_6859

        // omit label:
        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, isBlocked: true)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, PhoneCaller.labelPlaceholder)
        XCTAssertEqual(phoneCaller.isBlocked, true)
    }

    func testConvenienceInitIsBlockedDefault() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 802_745_6859

        // omit isBlocked:
        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, label: "foo")

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, "foo")
        XCTAssertEqual(phoneCaller.isBlocked, false)
    }

    func testConvenienceInitLabelEmptyStringIsBlockedDefault() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 01_802_745_6859
        let label = ""

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, label: label)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, label)
        XCTAssertEqual(phoneCaller.isBlocked, false)
    }

    func testConvenienceInitLabelDefaultIsBlockedDefault() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 802_745_6859

        // omit label: and isBlocked:
        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, PhoneCaller.labelPlaceholder)
        XCTAssertEqual(phoneCaller.isBlocked, false)
    }


    func testConvenienceInitPhoneNumberMaximumValueWith15DigitsDoesntRollOver() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 99999_99999_99999

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, isBlocked: true)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, PhoneCaller.labelPlaceholder)
        XCTAssertEqual(phoneCaller.isBlocked, true)
    }
    
}
