//
//  LongTableViewControllerTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/14/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import CallKitty

class LongTableViewControllerTests: XCTestCase {

    func testStatusStringAllTrue() {
        let phoneCaller = PhoneCaller(phoneNumber: 1234567890,
            label: "foo",
            hasChanges: true,
            shouldBlock: true,
            isBlocked: true,
            shouldIdentify: true,
            isIdentified: true,
            shouldDelete: true)

        XCTAssertEqual(LongTableViewController.statusString(phoneCaller: phoneCaller), "hc1sb1ib1si1ii1sd1")
    }

    func testStatusString() {
        let phoneCaller = PhoneCaller(phoneNumber: 1234567890,
                                      label: "foo",
                                      hasChanges: true,
                                      shouldBlock: true,
                                      isBlocked: false,
                                      shouldIdentify: true,
                                      isIdentified: false,
                                      shouldDelete: false)

        XCTAssertEqual(LongTableViewController.statusString(phoneCaller: phoneCaller), "hc1sb1ib0si1ii0sd0")
    }

    func testStatusColorAllTrue() {
        let phoneCaller = PhoneCaller(phoneNumber: 1234567890,
                                      label: "foo",
                                      hasChanges: true,
                                      shouldBlock: true,
                                      isBlocked: true,
                                      shouldIdentify: true,
                                      isIdentified: true,
                                      shouldDelete: true)

        XCTAssertEqual(LongTableViewController.statusColor(phoneCaller: phoneCaller), .lightGray)
    }
    
    func testStatusColorShouldBlock() {
        let phoneCaller = PhoneCaller(phoneNumber: 1234567890,
                                      label: "foo",
                                      hasChanges: true,
                                      shouldBlock: true,
                                      isBlocked: false,
                                      shouldIdentify: false,
                                      isIdentified: false,
                                      shouldDelete: false)

        XCTAssertEqual(LongTableViewController.statusColor(phoneCaller: phoneCaller), UIColor.callKittyPaleRed())
    }

    func testStatusColorShouldIdentify() {
        let phoneCaller = PhoneCaller(phoneNumber: 1234567890,
                                      label: "foo",
                                      hasChanges: true,
                                      shouldBlock: false,
                                      isBlocked: false,
                                      shouldIdentify: true,
                                      isIdentified: false,
                                      shouldDelete: false)

        XCTAssertEqual(LongTableViewController.statusColor(phoneCaller: phoneCaller), UIColor.callKittyPaleYellow())
    }

    func testStatusColorShouldBlockShouldIdentify() {
        let phoneCaller = PhoneCaller(phoneNumber: 1234567890,
                                      label: "foo",
                                      hasChanges: true,
                                      shouldBlock: true,
                                      isBlocked: false,
                                      shouldIdentify: true,
                                      isIdentified: false,
                                      shouldDelete: false)

        XCTAssertEqual(LongTableViewController.statusColor(phoneCaller: phoneCaller), .orange)
    }

    func testStatusColorAllFalse() {
        let phoneCaller = PhoneCaller(phoneNumber: 1234567890,
                                      label: "foo",
                                      hasChanges: false,
                                      shouldBlock: false,
                                      isBlocked: false,
                                      shouldIdentify: false,
                                      isIdentified: false,
                                      shouldDelete: false)

        XCTAssertEqual(LongTableViewController.statusColor(phoneCaller: phoneCaller), .white)
    }
}
