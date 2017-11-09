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
        XCTAssertFalse(phoneCaller.isBlocked)

        realmService.add(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount + 1)

        // use enum PhoneCaller.PropertyStrings to reduce risk of misspelling a "stringly typed" key
        realmService.update(phoneCaller, with: [PhoneCaller.PropertyStrings.phoneNumber.rawValue : 456])

        XCTAssertEqual(phoneCaller.phoneNumber, 456)
        XCTAssertEqual(phoneCaller.label, "dog")
        XCTAssertFalse(phoneCaller.isBlocked)

        realmService.update(phoneCaller, with: [PhoneCaller.PropertyStrings.label.rawValue : "cat",
                                                PhoneCaller.PropertyStrings.isBlocked.rawValue : true])

        XCTAssertEqual(phoneCaller.phoneNumber, 456)
        XCTAssertEqual(phoneCaller.label, "cat")
        XCTAssertTrue(phoneCaller.isBlocked)

        realmService.delete(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount)
    }

}
