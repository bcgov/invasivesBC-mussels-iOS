//
//  WatercraftRiskAssessment.swift
//  ipadTests
//
//  Created by Pushan  on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import XCTest
@testable import Boilerplate
class WatercraftRiskAssessment: XCTestCase {
    let api: WatercraftRiskAssessmentAPI = WatercraftRiskAssessmentAPI.api()
    let workflow: WorkflowAPI = WorkflowAPI.api()
    var promise: Promise<Any>?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWatercraftRiskAssessmentPost() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = XCTestExpectation(description: "Create Workflow")
        // Create workflow
        let p1 = workflow.post([
            "date" : "2019-10-20",
            "startOfDayForm": [ "test" : "From ios"],
            "endOfDayForm": ["test": "From ipad"],
            "info": ["test" : "testing"]
        ])
        p1?.then({ (data, resp) in
            if let map: [String: Any] = data as? [String : Any], let id: Int = map["observer_workflow_id"] as? Int {
                InfoLog("SUCESS => \(id)")
                setTimeout(time: 0.1) {
                    // Call WRA API
                    InfoLog("Calling API")
                    self.promise = self.api.post([
                        "timestamp" : "2019-08-11 12:31:45",
                        "workflow": id,
                        "highRiskAssessmentForm": [ "test" : "From ios"],
                        "lowRiskAssessmentForm": ["test": "From ipad"],
                        "fullObservationForm": ["test" : "testing"],
                        "additionalInfo": ["test" : "testing"]
                    ])
                    self.promise?.then({ (dat, resp) in
                        guard let data = dat as? [String : Any] else {
                            XCTAssert(false)
                            expectation.fulfill()
                            return
                        }
                        let map: [String : Any] = resp as? [String : Any] ?? [:]
                        XCTAssertNotNil(map)
                        XCTAssertNotNil(data["timestamp"])
                        XCTAssertNotNil(data["highRiskAssessmentForm"])
                        XCTAssertNotNil(data["lowRiskAssessmentForm"])
                        XCTAssertNotNil(data["fullObservationForm"])
                        XCTAssertNotNil(data["additionalInfo"])
                        expectation.fulfill()
                    })
                    self.promise?.error({ (e, _) in
                        XCTAssertNil(e)
                        expectation.fulfill()
                    })
                }
            } else {
                InfoLog("\(data)")
                InfoLog("NO ID")
                XCTAssert(false)
                expectation.fulfill()
            }
        })
        wait(for: [expectation], timeout: 25.0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
