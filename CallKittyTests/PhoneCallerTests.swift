//
//  PhoneCallerTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import CallKitty

class PhoneCallerTests: XCTestCase {
    
    func testConvenienceInit() {

        let phoneNumberString = "1234567890"
        let label = "foo"

        let phoneCaller = PhoneCaller(phoneNumberString: phoneNumberString, label: label)

        XCTAssertEqual(phoneCaller.phoneNumberString, phoneNumberString)
        XCTAssertEqual(phoneCaller.label, label)
    }

    func testConvenienceInitLabelNil() {

        let phoneNumberString = "abc123+;()?hij494"
        let label: String? = nil

        let phoneCaller = PhoneCaller(phoneNumberString: phoneNumberString, label: label)

        XCTAssertEqual(phoneCaller.phoneNumberString, phoneNumberString)
        XCTAssertEqual(phoneCaller.label, label)
    }
    
}
