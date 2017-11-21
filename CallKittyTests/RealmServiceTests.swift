//
//  RealmServiceTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
import CallKit
import RealmSwift
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

        let realm = try! Realm(configuration: RealmService.configuration())
        let phoneCallers = realm.objects(PhoneCaller.self)
            .sorted(byKeyPath: PhoneCaller.PropertyStrings.phoneNumber.rawValue)

        let initialCount = phoneCallers.count

        let phoneCaller = PhoneCaller(phoneNumber: 300, label: "dog")

        XCTAssertEqual(phoneCaller.phoneNumber, 300)
        XCTAssertEqual(phoneCaller.label, "dog")
        XCTAssertFalse(phoneCaller.shouldBlock)

        RealmService.add(phoneCaller, realm: realm)
        XCTAssertEqual(phoneCallers.count, initialCount + 1)

        // use enum PhoneCaller.PropertyStrings to reduce risk of misspelling a "stringly typed" key
        // can't change phoneNumber because it is a primary key
        RealmService.update(phoneCaller,
                            dictionary: [PhoneCaller.PropertyStrings.label.rawValue : "cat",
                                                PhoneCaller.PropertyStrings.shouldBlock.rawValue : true],
                            realm: realm)

        XCTAssertEqual(phoneCaller.phoneNumber, 300)
        XCTAssertEqual(phoneCaller.label, "cat")
        XCTAssertTrue(phoneCaller.shouldBlock)

        RealmService.delete(phoneCaller, realm: realm)
        XCTAssertEqual(phoneCallers.count, initialCount)
    }

    func testIsBlockedCount() {
        let realm = try! Realm(configuration: RealmService.configuration())
        let initialCount = RealmService.getAllPhoneCallersIsBlockedSortedCount(realm: realm)

        // normally a newly instantiated caller will have isBlocked false until it is added to call directory
        // for this unit test, set it true
        let phoneCaller = PhoneCaller(phoneNumber: 301, label: "dog", isBlocked: true)

        RealmService.add(phoneCaller, realm: realm)

        XCTAssertEqual(RealmService.getAllPhoneCallersIsBlockedSortedCount(realm: realm),
                       initialCount + 1)

        RealmService.update(phoneCaller,
                            dictionary: [PhoneCaller.PropertyStrings.isBlocked.rawValue : false],
                            realm: realm)

        XCTAssertEqual(RealmService.getAllPhoneCallersIsBlockedSortedCount(realm: realm),
                       initialCount)

        // clean up
        RealmService.delete(phoneCaller, realm: realm)
    }

    func testIsIdentifiedCount() {
        let realm = try! Realm(configuration: RealmService.configuration())
        let initialCount = RealmService.getAllPhoneCallersIsIdentifiedSortedCount(realm: realm)

        // normally a newly instantiated caller will have isIdentified false until it is added to call directory
        // for this unit test, set it true
        let phoneCaller0 = PhoneCaller(phoneNumber: 302, label: "dog", shouldBlock: true, isIdentified: true)
        RealmService.add(phoneCaller0, realm: realm)
        XCTAssertEqual(RealmService.getAllPhoneCallersIsIdentifiedSortedCount(realm: realm), initialCount + 1)

        let phoneCaller1 = PhoneCaller(phoneNumber: 303, isIdentified: false)
        RealmService.add(phoneCaller1, realm: realm)
        XCTAssertEqual(RealmService.getAllPhoneCallersIsIdentifiedSortedCount(realm: realm),
                       initialCount + 1)

        RealmService.update(phoneCaller0,
                            dictionary: [PhoneCaller.PropertyStrings.isIdentified.rawValue: false],
                            realm: realm)

        XCTAssertEqual(RealmService.getAllPhoneCallersIsIdentifiedSortedCount(realm: realm), initialCount)

        // clean up
        RealmService.delete(phoneCaller0, realm: realm)
        RealmService.delete(phoneCaller1, realm: realm)
    }

    func testGetAllPhoneCallersShouldBlockOrIsBlockedSorted() {
        let realm = try! Realm(configuration: RealmService.configuration())
        let initialCount = RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realm).count

        let phoneCaller0 = PhoneCaller(phoneNumber: 400, label: "rhino", shouldBlock: false, isBlocked: false)
        RealmService.add(phoneCaller0, realm: realm)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realm).count,
                       initialCount)

        let phoneCaller1 = PhoneCaller(phoneNumber: 401, label: "elephant", shouldBlock: true, isBlocked: false)
        RealmService.add(phoneCaller1, realm: realm)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realm).count,
                       initialCount + 1)

        let phoneCaller2 = PhoneCaller(phoneNumber: 402, label: "elephant", shouldBlock: false, isBlocked: true)
        RealmService.add(phoneCaller2, realm: realm)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realm).count,
                       initialCount + 2)

        let phoneCaller3 = PhoneCaller(phoneNumber: 403, label: "elephant", shouldBlock: true, isBlocked: true)
        RealmService.add(phoneCaller3, realm: realm)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realm).count,
                       initialCount + 3)

        RealmService.delete(phoneCaller3, realm: realm)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realm).count,
                       initialCount + 2)

        RealmService.delete(phoneCaller2, realm: realm)
        RealmService.delete(phoneCaller1, realm: realm)

        XCTAssertEqual(RealmService.getAllPhoneCallersShouldBlockOrIsBlockedSorted(realm: realm).count,
                       initialCount)

        // clean up last phoneCaller
        RealmService.delete(phoneCaller0, realm: realm)
    }

    func testGetAllPhoneCallersShouldDeleteSorted() {

        let realm = try! Realm(configuration: RealmService.configuration())

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
        RealmService.delete(phoneCaller!, realm: realm)
        XCTAssertEqual(RealmService.getAllPhoneCallersShouldDeleteSorted(realm: realm).count, initialCount)
    }
}
