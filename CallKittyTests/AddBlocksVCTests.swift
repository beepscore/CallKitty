//
//  AddBlocksVCTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/11/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import CallKitty

class AddBlocksVCTests: XCTestCase {
    
    func testNumberToGenerateExponentLessThanZero() {
        XCTAssertEqual(AddBlocksVC.numberToGenerate(exponent: -0.01), 1)
    }
    
    func testNumberToGenerateExponentZero() {
        XCTAssertEqual(AddBlocksVC.numberToGenerate(exponent: 0.0), 1)
    }

    func testNumberToGenerateExponentOne() {
        XCTAssertEqual(AddBlocksVC.numberToGenerate(exponent: 1.0), 10)
    }

    func testNumberToGenerateExponentFour() {
        XCTAssertEqual(AddBlocksVC.numberToGenerate(exponent: 4.0), 10_000)
    }

    func testNumberToGenerateExponentFive() {
        XCTAssertEqual(AddBlocksVC.numberToGenerate(exponent: 5.0), 100_000)
    }

    func testNumberToGenerateExponentGreaterThanFive() {
        XCTAssertEqual(AddBlocksVC.numberToGenerate(exponent: 7.5), 100_000)
    }
}
