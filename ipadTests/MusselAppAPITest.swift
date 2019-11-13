//
//  MusselAppAPITest.swift
//  ipadTests
//
//  Created by Pushan  on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import XCTest
@testable import Boilerplate

class MusselAppAPITest: XCTestCase {
    let waterBodyAPI: WaterBodyAPI =  WaterBodyAPI.api()
    let codesAPI: CodesAPI = CodesAPI.api()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetCodes() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = XCTestExpectation(description: "Get water-bodies")
        let promise = codesAPI.get()
        promise?.then({ (resp, _) in
            guard let data: [String: Any] = resp as? [String: Any] else {
                XCTAssert(false, "FAIL: Wrong resp")
                expectation.fulfill()
                return
            }
            XCTAssertNotNil(data["observers"], "PASS: observers")
            XCTAssertNotNil(data["otherObservations"], "PASS: otherObservations")
            XCTAssertNotNil(data["stations"], "PASS: stations")
            XCTAssertNotNil(data["watercraftList"], "PASS: watercraftList")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20.0)
    }

    func testWaterBody() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = XCTestExpectation(description: "Get water-bodies")
        let promise = waterBodyAPI.get()
        promise?.then({ (resp, _) in
            guard let resp: [[String : Any]] = resp as? [[String: Any]] else {
                XCTAssert(false, "FAIL: Wrong resp")
                expectation.fulfill()
                return
            }
            XCTAssert(resp.count > 0, "PASS: list is not empty")
            guard let item: [String: Any] = resp.first else {
                XCTAssert(false, "FAIL: No first item")
                expectation.fulfill()
                return
            }
            XCTAssertNotNil(item["name"], "PASS: name")
            XCTAssertNotNil(item["water_body_id"], "PASS: water_body_id")
            XCTAssertNotNil(item["closest"], "PASS: closest")
            XCTAssertNotNil(item["abbrev"], "PASS: abbrev")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20.0)
    }

}
