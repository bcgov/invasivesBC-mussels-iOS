//
//  WorkflowAPITest.swift
//  ipadTests
//
//  Created by Pushan  on 2019-11-08.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import XCTest
@testable import Boilerplate

class WorkflowAPITest: XCTestCase {
    let api: WorkflowAPI = WorkflowAPI.api()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPost() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = XCTestExpectation(description: "Create Workflow")
        let promise = api.post([
            "date" : "2019-10-20",
            "startOfDayForm": [ "test" : "From ios"],
            "endOfDayForm": ["test": "From ipad"],
            "info": ["test" : "testing"]
        ])
        promise?.then({ (dat, resp) in
            guard let data = dat as? [String : Any] else {
                XCTAssert(false)
                expectation.fulfill()
                return
            }
            let map: [String : Any] = resp as? [String : Any] ?? [:]
            XCTAssertNotNil(map)
            XCTAssertNotNil(map["data"])
            XCTAssertNotNil(data["endOfDayForm"])
            XCTAssertNotNil(data["startOfDayForm"])
            XCTAssertNotNil(data["observer_workflow_id"])
            expectation.fulfill()
        })
        promise?.error({ (e, _) in
            XCTAssertNil(e)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20.0)
        
    }
    
    func testPostFail() {
        let expectation = XCTestExpectation(description: "Create Workflow Fail")
        let promiseFail = api.post([
            "startOfDayForm": [ "test" : "From ios"],
            "endOfDayForm": ["test": "From ipad"],
            "info": ["test" : "testing"]
        ])
        promiseFail?.error({ (e, errorDetail) in
            XCTAssertNotNil(e)
            InfoLog("\(errorDetail ?? "NA")")
            XCTAssertNotNil(errorDetail)
            InfoLog("\(errorDetail ?? "")")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testGet() {
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
        }
    }

}
