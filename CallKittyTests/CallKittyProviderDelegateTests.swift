//
//  CallKittyProviderDelegateTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/7/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import CallKitty

class CallKittyProviderDelegateTests: XCTestCase {

    func testInit() {
        let callManager = CallKittyCallManager()
        let providerDelegate = ProviderDelegate(callManager: callManager)

        XCTAssertEqual(providerDelegate.callManager, callManager)
    }
}
