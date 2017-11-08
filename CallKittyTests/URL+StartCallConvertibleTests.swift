//
//  URL+StartCallConvertibleTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/7/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import CallKitty

class URL_StartCallConvertibleTests: XCTestCase {

    func testStartCallHandleSchemecallkittyHostFoo() {
        let url = URL(string: "callkitty://foo")
        XCTAssertEqual(url!.scheme, "callkitty")
        XCTAssertEqual(url!.host, "foo")
        XCTAssertEqual(url!.startCallHandle, "foo")
    }

    func testStartCallHandleSchemecallkittyHostNil() {
        let url = URL(string: "callkitty://")
        XCTAssertEqual(url!.scheme, "callkitty")
        XCTAssertNil(url!.host)
        XCTAssertNil(url!.startCallHandle)
    }

    func testStartCallHandleSchemehttps() {
        let url = URL(string: "https://www.foo.com")
        XCTAssertEqual(url!.scheme, "https")
        XCTAssertEqual(url!.host, "www.foo.com")
        XCTAssertNil(url!.startCallHandle)
    }
    
}
