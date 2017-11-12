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
//    func testAddUpdatePhoneCallers() {
//        let realm = RealmService.shared.realm
//        RealmService.addUpdatePhoneCaller(phoneNumber: 100, label: "dog", shouldBlock: true, realm: realm)
//        RealmService.addUpdatePhoneCaller(phoneNumber: 101, label: "cat", shouldBlock: true, realm: realm)
//        RealmService.addUpdatePhoneCaller(phoneNumber: 102, label: "civet", shouldBlock: false, realm: realm)
//    }

    // can comment out to avoid altering realm database
//    func testAddBlockingPhoneCallers() {
//        let realm = RealmService.shared.realm
//        RealmService.addBlockingPhoneCallers(count: 10, realm: realm)
//    }

    func testShared() {
        XCTAssertNotNil(RealmService.shared)
    }

    // MARK: - test PhoneCaller specific methods

    func testGetPhoneCaller() {

        let realmService = RealmService.shared
        let realm = realmService.realm

        let fetchedPhoneCaller = RealmService.getPhoneCaller(phoneNumber: 200, realm: realm)
        XCTAssertNil(fetchedPhoneCaller)
    }

    func testPhoneCallerGetAddUpdateDelete() {

        let realmService = RealmService.shared
        let realm = realmService.realm

        let phoneCallers = RealmService.getAllPhoneCallers(realm: realm)

        let initialCount = phoneCallers.count

        RealmService.addUpdatePhoneCaller(phoneNumber: 201,
                                          label: "dog",
                                          hasChanges: true,
                                          shouldBlock: false,
                                          isBlocked: false,
                                          shouldIdentify: true,
                                          isIdentified: false,
                                          shouldDelete: false,
                                          realm: realm)

        var fetchedPhoneCaller = RealmService.getPhoneCaller(phoneNumber: 201, realm: realm)
        XCTAssertEqual(fetchedPhoneCaller?.phoneNumber, 201)
        XCTAssertEqual(fetchedPhoneCaller?.label, "dog")
        XCTAssertFalse((fetchedPhoneCaller?.shouldBlock)!)

        XCTAssertEqual(phoneCallers.count, initialCount + 1)

        // can't change phoneNumber because it is a primary key
        RealmService.addUpdatePhoneCaller(phoneNumber: 201,
                                          label: "cat",
                                          hasChanges: true,
                                          shouldBlock: true,
                                          isBlocked: false,
                                          shouldIdentify: true,
                                          isIdentified: false,
                                          shouldDelete: false,
                                          realm: realm)

        fetchedPhoneCaller = RealmService.getPhoneCaller(phoneNumber: 201, realm: realm)
        XCTAssertEqual(fetchedPhoneCaller?.phoneNumber, 201)
        XCTAssertEqual(fetchedPhoneCaller?.label, "cat")
        XCTAssertTrue((fetchedPhoneCaller?.shouldBlock)!)

        let _ = RealmService.deletePhoneCaller(phoneNumber: 201, realm: realm)
        XCTAssertEqual(phoneCallers.count, initialCount)
    }

    // MARK: - test generic functions

    func testReadAddUpdateDelete() {

        let realmService = RealmService.shared
        let phoneCallers = realmService.realm.objects(PhoneCaller.self)
            .sorted(byKeyPath: PhoneCaller.PropertyStrings.phoneNumber.rawValue)

        let initialCount = phoneCallers.count

        let phoneCaller = PhoneCaller(phoneNumber: 300, label: "dog")

        XCTAssertEqual(phoneCaller.phoneNumber, 300)
        XCTAssertEqual(phoneCaller.label, "dog")
        XCTAssertFalse(phoneCaller.shouldBlock)

        realmService.add(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount + 1)

        // use enum PhoneCaller.PropertyStrings to reduce risk of misspelling a "stringly typed" key
        // can't change phoneNumber because it is a primary key
        realmService.update(phoneCaller, with: [PhoneCaller.PropertyStrings.label.rawValue : "cat",
                                                PhoneCaller.PropertyStrings.shouldBlock.rawValue : true])

        XCTAssertEqual(phoneCaller.phoneNumber, 300)
        XCTAssertEqual(phoneCaller.label, "cat")
        XCTAssertTrue(phoneCaller.shouldBlock)

        realmService.delete(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount)
    }

    func testBlockedCount() {
        let realmService = RealmService.shared
        let initialCount = RealmService.getAllPhoneCallersBlockedSortedCount(realm: realmService.realm)

        let phoneCaller = PhoneCaller(phoneNumber: 301, label: "dog", shouldBlock: true)

        realmService.add(phoneCaller)

        XCTAssertEqual(RealmService.getAllPhoneCallersBlockedSortedCount(realm: realmService.realm),
                       initialCount + 1)

        realmService.update(phoneCaller, with: [PhoneCaller.PropertyStrings.shouldBlock.rawValue : false])

        XCTAssertEqual(RealmService.getAllPhoneCallersBlockedSortedCount(realm: realmService.realm),
                       initialCount)

        // clean up
        realmService.delete(phoneCaller)
    }

    func testIdentifiedCount() {
        let realmService = RealmService.shared
        let initialCount = RealmService.getAllPhoneCallersIdentifiedSortedCount(realm: realmService.realm)

        let phoneCaller0 = PhoneCaller(phoneNumber: 302, label: "dog", shouldBlock: true)
        realmService.add(phoneCaller0)
        XCTAssertEqual(RealmService.getAllPhoneCallersIdentifiedSortedCount(realm: realmService.realm), initialCount + 1)

        let phoneCaller1 = PhoneCaller(phoneNumber: 303)
        realmService.add(phoneCaller1)
        XCTAssertEqual(RealmService.getAllPhoneCallersIdentifiedSortedCount(realm: realmService.realm),
                       initialCount + 1)

        realmService.update(phoneCaller0,
                            with: [PhoneCaller.PropertyStrings.label.rawValue: PhoneCaller.labelPlaceholder])

        XCTAssertEqual(RealmService.getAllPhoneCallersIdentifiedSortedCount(realm: realmService.realm),
                       initialCount)

        // clean up
        realmService.delete(phoneCaller0)
        realmService.delete(phoneCaller1)
    }

}
