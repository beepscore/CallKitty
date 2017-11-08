//
//  CallKittyCallTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/7/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import CallKitty

class CallKittyCallTests: XCTestCase {
    
    func testInit() {
        let uuid = UUID()
        let call = CallKittyCall(uuid: uuid, isOutgoing: false)
        XCTAssertEqual(call.uuid, uuid)
        XCTAssertEqual(call.isOutgoing, false)
        XCTAssertEqual(call.isOnHold, false)
        XCTAssertNil(call.connectingDate)
        XCTAssertEqual(call.duration, 0)
    }

}
