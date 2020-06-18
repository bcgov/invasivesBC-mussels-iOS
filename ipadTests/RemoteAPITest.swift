//
//  RemoteAPITest.swift
//  ipadTests
//
//  Created by Pushan  on 2019-11-08.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import XCTest
@testable import Inspect

let ApiURL: String = "https://dev-invasivesbc.pathfinder.gov.bc.ca/api/data"
class TestAPI: RemoteAPI<Data> {
    override class func apiURL() -> String {
        return ApiURL
    }
    
    override var urlOptions: [String] {
        return ["key1", "key2"]
    }
}

class DictAPI: RemoteAPI<[String: Any]> {
    override class func apiURL() -> String {
        return ApiURL
    }
}

class RemoteAPITest: XCTestCase {

    let api: TestAPI = TestAPI.api()
    let dictAPI: DictAPI = DictAPI.api()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testProcessDataOfDataAPI() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let d: Data = "".data
        if let p: Data = api.processData(data: d, more: nil).0 {
            XCTAssert(d.string == p.string)
        } else {
            XCTAssert(false)
        }
    }
    
    func testProcessDataOfDictAPI() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let d: [String : String] = ["k" : "v", "m" : "v1"]
        let data: Data = d.json()
        if let p: [String : String] = dictAPI.processData(data: data, more: nil).0 as? [String : String] {
            XCTAssert(d["k"] == p["k"])
        } else {
            XCTAssert(false)
        }
    }
    
    func checkURLOptions() {
        api.argMap = [
            "key1" : "lao",
            "key2" : "pungi"
        ]
        XCTAssertNotNil(api.url.contains("key1=lao"))
        XCTAssertNotNil(api.url.contains("key2=pungi"))
        XCTAssert(api.url == "https://dev-invasivesbc.pathfinder.gov.bc.ca/api/data?key1=lao&key2=pungi")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
