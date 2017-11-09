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

    func testPhoneNumberNil() {
        XCTAssertNil(PhoneNumberFormatter.phoneNumber(phoneNumberString: nil))
    }

}
