//
//  testShift.swift
//  ipadTests
//
//  Created by Amir Shayegh on 2019-12-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import XCTest
@testable import InvasivesBC

class testShift: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func createTestModel() -> ShiftModel {
        let model = ShiftModel()
        model.date = Date()
        // model.location = "Victoria, BC"
        return model
    }
    
    func createTestInspection() -> WatercradftInspectionModel {
        let inspection = WatercradftInspectionModel()
        inspection.remoteId = 1000
        inspection.inspectionTime = "16.00"
        inspection.shouldSync = false
        return inspection
    }
    
    func testNumberOfInputItems() {
        let model = ShiftModel()
        let shiftStartFields = model.getShiftStartFields(forModal: false, editable: true)
        let shiftEndFields = model.getShiftEndFields(editable: true)
        XCTAssert(shiftStartFields.count == 9 && shiftEndFields.count == 7)
    }
    
    func testInvalidShiftForSubmission() {
        let vc = ShiftViewController()
        let shiftModel = createTestModel()
        vc.setup(model: shiftModel)
        shiftModel.inspections.append(createTestInspection())
        shiftModel.boatsInspected = false
        XCTAssert(vc.canSubmit() == false && (shiftModel.startTime == "" || shiftModel.endTime == ""))
    }
    
    func testValidShiftForSubmission() {
        let vc = ShiftViewController()
        let shiftModel = createTestModel()
        vc.setup(model: shiftModel)
        shiftModel.startTime = "13:00"
        shiftModel.endTime = "18:00"
        shiftModel.inspections.append(createTestInspection())
        shiftModel.boatsInspected = true
        XCTAssert(vc.canSubmit() == true && (shiftModel.startTime != "" || shiftModel.endTime != ""))
    }

}
