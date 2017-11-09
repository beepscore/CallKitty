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
        let phoneCallers = realmService.realm.objects(PhoneCaller.self).sorted(byKeyPath: "phoneNumber")
        let initialCount = phoneCallers.count

        let phoneCaller = PhoneCaller(phoneNumber: 123, label: "dog")
        XCTAssertEqual(phoneCaller.label, "dog")

        realmService.add(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount + 1)

        realmService.update(phoneCaller, with: ["label" : "cat"])
        XCTAssertEqual(phoneCaller.label, "cat")

        realmService.delete(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount)
    }

}
