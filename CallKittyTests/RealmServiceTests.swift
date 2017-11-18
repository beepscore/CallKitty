//
//  RealmServiceTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
import CallKit
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

    // MARK: -

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

    func testIsBlockedCount() {
        let realmService = RealmService.shared
        let initialCount = RealmService.getAllPhoneCallersIsBlockedSortedCount(realm: realmService.realm)

        // normally a newly instantiated caller will have isBlocked false until it is added to call directory
        // for this unit test, set it true
        let phoneCaller = PhoneCaller(phoneNumber: 301, label: "dog", isBlocked: true)

        realmService.add(phoneCaller)

        XCTAssertEqual(RealmService.getAllPhoneCallersIsBlockedSortedCount(realm: realmService.realm),
                       initialCount + 1)

        realmService.update(phoneCaller, with: [PhoneCaller.PropertyStrings.isBlocked.rawValue : false])

        XCTAssertEqual(RealmService.getAllPhoneCallersIsBlockedSortedCount(realm: realmService.realm),
                       initialCount)

        // clean up
        realmService.delete(phoneCaller)
    }

    func testIsIdentifiedCount() {
        let realmService = RealmService.shared
        let initialCount = RealmService.getAllPhoneCallersIsIdentifiedSortedCount(realm: realmService.realm)

        // normally a newly instantiated caller will have isIdentified false until it is added to call directory
        // for this unit test, set it true
        let phoneCaller0 = PhoneCaller(phoneNumber: 302, label: "dog", shouldBlock: true, isIdentified: true)
        realmService.add(phoneCaller0)
        XCTAssertEqual(RealmService.getAllPhoneCallersIsIdentifiedSortedCount(realm: realmService.realm), initialCount + 1)

        let phoneCaller1 = PhoneCaller(phoneNumber: 303, isIdentified: false)
        realmService.add(phoneCaller1)
        XCTAssertEqual(RealmService.getAllPhoneCallersIsIdentifiedSortedCount(realm: realmService.realm),
                       initialCount + 1)

        realmService.update(phoneCaller0,
                            with: [PhoneCaller.PropertyStrings.isIdentified.rawValue: false])

        XCTAssertEqual(RealmService.getAllPhoneCallersIsIdentifiedSortedCount(realm: realmService.realm),
                       initialCount)

        // clean up
        realmService.delete(phoneCaller0)
        realmService.delete(phoneCaller1)
    }

    func testGetAllPhoneCallersShouldBlockOrIsBlockedSorted() {
        let realmService = RealmService.shared
        let initialCount = RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realmService.realm).count

        let phoneCaller0 = PhoneCaller(phoneNumber: 400, label: "rhino", shouldBlock: false, isBlocked: false)
        realmService.add(phoneCaller0)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realmService.realm).count,
                       initialCount)

        let phoneCaller1 = PhoneCaller(phoneNumber: 401, label: "elephant", shouldBlock: true, isBlocked: false)
        realmService.add(phoneCaller1)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realmService.realm).count,
                       initialCount + 1)

        let phoneCaller2 = PhoneCaller(phoneNumber: 402, label: "elephant", shouldBlock: false, isBlocked: true)
        realmService.add(phoneCaller2)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realmService.realm).count,
                       initialCount + 2)

        let phoneCaller3 = PhoneCaller(phoneNumber: 403, label: "elephant", shouldBlock: true, isBlocked: true)
        realmService.add(phoneCaller3)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realmService.realm).count,
                       initialCount + 3)

        realmService.delete(phoneCaller3)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realmService.realm).count,
                       initialCount + 2)

        realmService.delete(phoneCaller2)
        realmService.delete(phoneCaller1)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realmService.realm).count,
                       initialCount)

        // clean up last phoneCaller
        realmService.delete(phoneCaller0)
    }

    func testGetAllPhoneCallersShouldDeleteSorted() {

        let realmService = RealmService.shared
        let realm = realmService.realm

        let initialCount = RealmService.getAllPhoneCallersShouldDeleteSorted(realm: realm).count
        let phoneNumber: CXCallDirectoryPhoneNumber = 500

        RealmService.addUpdatePhoneCaller(phoneNumber: phoneNumber,
                                          label: "dog",
                                          hasChanges: true,
                                          shouldBlock: false,
                                          isBlocked: false,
                                          shouldIdentify: true,
                                          isIdentified: false,
                                          shouldDelete: false,
                                          realm: realm)
        XCTAssertEqual(RealmService.getAllPhoneCallersShouldDeleteSorted(realm: realm).count, initialCount)

        RealmService.addUpdatePhoneCaller(phoneNumber: phoneNumber,
                                          label: "dog",
                                          hasChanges: true,
                                          shouldBlock: false,
                                          isBlocked: false,
                                          shouldIdentify: true,
                                          isIdentified: false,
                                          shouldDelete: true,
                                          realm: realm)
        XCTAssertEqual(RealmService.getAllPhoneCallersShouldDeleteSorted(realm: realm).count, initialCount + 1)

        let phoneCaller = RealmService.getPhoneCaller(phoneNumber: phoneNumber, realm: realm)
        realmService.delete(phoneCaller!)
        XCTAssertEqual(RealmService.getAllPhoneCallersShouldDeleteSorted(realm: realm).count, initialCount)
    }
}
