//
//  CallKittyProviderDelegateTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/7/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
import CallKit
@testable import CallKitty

class CallKittyProviderDelegateTests: XCTestCase {

    func testInit() {
        let callManager = CallKittyCallManager()
        let providerDelegate = ProviderDelegate(callManager: callManager)

        XCTAssertEqual(providerDelegate.callManager, callManager)
    }

    func testProviderConfiguration() {
        let providerConfiguration = ProviderDelegate.providerConfiguration
        XCTAssertEqual(providerConfiguration.localizedName, "CallKitty")
        XCTAssertTrue(providerConfiguration.supportsVideo)

        // test class must import CallKit to avoid build failure
        XCTAssertEqual(providerConfiguration.supportedHandleTypes, [.phoneNumber])

        XCTAssertEqual(providerConfiguration.ringtoneSound, "Ringtone.aif")
    }
}
