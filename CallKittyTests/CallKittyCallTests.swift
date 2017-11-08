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

        XCTAssertNil(call.connectDate)
        XCTAssertNil(call.connectingDate)
        XCTAssertEqual(call.duration, 0)
        XCTAssertNil(call.endDate)
        XCTAssertEqual(call.isOnHold, false)
        XCTAssertEqual(call.isOutgoing, false)
        XCTAssertNil(call.handle)
    }

}
