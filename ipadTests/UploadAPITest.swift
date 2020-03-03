//
//  UploadAPITest.swift
//  ipadTests
//
//  Created by Pushan  on 2020-03-04.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import XCTest
@testable import InvasivesBC

class UploadAPITest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpload() {
        // Expectation
        let expectation = XCTestExpectation(description: "Upload File")
        // Get logger file path
        let urls = ApplicationLogger.defalutLogger.logsURLs()
        APIRequest.uploadFile(fileURL: urls[0], info: ["name": "ios_log.txt"]) { (sucess) in
            XCTAssert(sucess, "UploadTest: FAIL")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 100)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
