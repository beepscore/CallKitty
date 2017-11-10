//
//  RealmServiceTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import CallKitty

class RealmServiceTests: XCTestCase {

    /// helper method to populate realm with some objects for testing
//    func testAddPhoneCallers() {
//        let realmService = RealmService.shared
//
//        let phoneCaller0 = PhoneCaller(phoneNumber: 123, label: "dog", shouldBlock: true)
//        realmService.add(phoneCaller0)
//        let phoneCaller1 = PhoneCaller(phoneNumber: 111, label: "cat", shouldBlock: true)
//        realmService.add(phoneCaller1)
//        let phoneCaller2 = PhoneCaller(phoneNumber: 111, label: "civet", shouldBlock: false)
//        realmService.add(phoneCaller2)
//    }

    func testShared() {
        XCTAssertNotNil(RealmService.shared)
    }

    func testReadAddUpdateDelete() {

        let realmService = RealmService.shared
        let phoneCallers = realmService.realm.objects(PhoneCaller.self)
            .sorted(byKeyPath: PhoneCaller.PropertyStrings.phoneNumber.rawValue)

        let initialCount = phoneCallers.count

        let phoneCaller = PhoneCaller(phoneNumber: 123, label: "dog")

        XCTAssertEqual(phoneCaller.phoneNumber, 123)
        XCTAssertEqual(phoneCaller.label, "dog")
        XCTAssertFalse(phoneCaller.shouldBlock)

        realmService.add(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount + 1)

        // use enum PhoneCaller.PropertyStrings to reduce risk of misspelling a "stringly typed" key
        realmService.update(phoneCaller, with: [PhoneCaller.PropertyStrings.phoneNumber.rawValue : 456])

        XCTAssertEqual(phoneCaller.phoneNumber, 456)
        XCTAssertEqual(phoneCaller.label, "dog")
        XCTAssertFalse(phoneCaller.shouldBlock)

        realmService.update(phoneCaller, with: [PhoneCaller.PropertyStrings.label.rawValue : "cat",
                                                PhoneCaller.PropertyStrings.shouldBlock.rawValue : true])

        XCTAssertEqual(phoneCaller.phoneNumber, 456)
        XCTAssertEqual(phoneCaller.label, "cat")
        XCTAssertTrue(phoneCaller.shouldBlock)

        realmService.delete(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount)
    }

    func testBlockedCount() {
        let realmService = RealmService.shared
        let initialCount = realmService.blockedCount()

        let phoneCaller = PhoneCaller(phoneNumber: 123, label: "dog", shouldBlock: true)
        realmService.add(phoneCaller)
        XCTAssertEqual(realmService.blockedCount(), initialCount + 1)

        realmService.update(phoneCaller, with: [PhoneCaller.PropertyStrings.shouldBlock.rawValue : false])

        XCTAssertEqual(realmService.blockedCount(), initialCount)

        // clean up
        realmService.delete(phoneCaller)
    }

    func testIdentifiedCount() {
        let realmService = RealmService.shared
        let initialCount = realmService.identifiedCount()

        let phoneCaller0 = PhoneCaller(phoneNumber: 123, label: "dog", shouldBlock: true)
        realmService.add(phoneCaller0)
        XCTAssertEqual(realmService.identifiedCount(), initialCount + 1)

        let phoneCaller1 = PhoneCaller(phoneNumber: 123)
        realmService.add(phoneCaller1)
        XCTAssertEqual(realmService.identifiedCount(), initialCount + 1)

        realmService.update(phoneCaller0,
                            with: [PhoneCaller.PropertyStrings.label.rawValue: PhoneCaller.labelPlaceholder])

        XCTAssertEqual(realmService.identifiedCount(), initialCount)

        // clean up
        realmService.delete(phoneCaller0)
        realmService.delete(phoneCaller1)
    }

}
