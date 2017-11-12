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
        let shouldBlock = true

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, label: label, shouldBlock: shouldBlock)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, label)

        XCTAssertTrue(phoneCaller.hasChanges)

        XCTAssertEqual(phoneCaller.shouldBlock, shouldBlock)
        XCTAssertFalse(phoneCaller.isBlocked)

        // Note non-empty label should automatically set shouldIdentify
        XCTAssertTrue(phoneCaller.shouldIdentify)
        XCTAssertFalse(phoneCaller.isIdentified)

        XCTAssertFalse(phoneCaller.shouldDelete)
    }

    func testConvenienceInitLabelDefault() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 802_745_6859

        // omit label:
        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, shouldBlock: true)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, PhoneCaller.labelPlaceholder)
        XCTAssertEqual(phoneCaller.shouldBlock, true)
    }

    func testConvenienceInitShouldBlockDefault() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 802_745_6859

        // omit shouldBlock:
        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, label: "foo")

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, "foo")
        XCTAssertEqual(phoneCaller.shouldBlock, false)
    }

    func testConvenienceInitLabelEmptyStringShouldBlockDefault() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 01_802_745_6859
        let label = ""

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, label: label)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, label)
        XCTAssertEqual(phoneCaller.shouldBlock, false)
    }

    func testConvenienceInitLabelDefaultShouldBlockDefault() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 802_745_6859

        // omit label: and shouldBlock:
        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, PhoneCaller.labelPlaceholder)
        XCTAssertEqual(phoneCaller.shouldBlock, false)
    }


    func testConvenienceInitPhoneNumberMaximumValueWith15DigitsDoesntRollOver() {

        // Swift numeric literal can contain underscores to increase readability
        let phoneNumber: CXCallDirectoryPhoneNumber = 99999_99999_99999

        let phoneCaller = PhoneCaller(phoneNumber: phoneNumber, shouldBlock: true)

        XCTAssertEqual(phoneCaller.phoneNumber, phoneNumber)
        XCTAssertEqual(phoneCaller.label, PhoneCaller.labelPlaceholder)
        XCTAssertEqual(phoneCaller.shouldBlock, true)
    }
    
}
