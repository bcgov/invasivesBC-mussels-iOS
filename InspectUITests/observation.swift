//
//  observation.swift
//  InspectUITests
//
//  Created by Amir Shayegh on 2020-06-22.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import XCTest

class observation: XCTestCase {
    
    let exists = NSPredicate(format: "exists == 1")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let app = XCUIApplication()

        // if app.buttons["Login with IDIR"].exists {
        if app.buttons["Login with BCeID"].exists {
            login()
        }
        
        let newShiftButton = app.buttons["Add New Shift"]
        expectation(for: exists, evaluatedWith: newShiftButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(app.buttons["Add New Shift"].exists, "New Shift Button Exists")
        app.buttons["Add New Shift"].tap()
        
        if app.buttons["Start Now"].exists {
            app.buttons["Start Now"].tap()
        }

        app.collectionViews["shiftform"].buttons["Add Inspection"].tap()

        let cellsQuery = app.collectionViews.cells.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Is this a Passport Holder?").children(matching: .other).element.children(matching: .other).element(boundBy: 0).tap()
        
        if app.navigationBars["Watercraft Inspection"].exists {
            app.navigationBars["Watercraft Inspection"].buttons["selected"].tap()
        }
        
        if app.navigationBars["Shift Overview"].exists {
            app.navigationBars["Shift Overview"].buttons["Delete"].tap()
            app.buttons["Yes"].tap()
        }
    }

    func login() {
        let app = XCUIApplication()
//        let loginButton = app.buttons["Login with IDIR"]
        let loginButton = app.buttons["Login with BCeID"]
        loginButton.tap()
        
        let accountUsername = ProcessInfo.processInfo.environment["TestBCeID"]!
        let accountPassword = ProcessInfo.processInfo.environment["TestPassword"]!
        
        let webViewsQuery = app.webViews.webViews.webViews
        let governmentOfBritishColumbiaElement = webViewsQuery.otherElements["Government of British Columbia"]
        governmentOfBritishColumbiaElement.children(matching: .textField).element.tap()
        governmentOfBritishColumbiaElement.children(matching: .textField).element.typeText(accountUsername)
        governmentOfBritishColumbiaElement.children(matching: .secureTextField).element.tap()
        governmentOfBritishColumbiaElement.children(matching: .secureTextField).element.typeText(accountPassword)
        webViewsQuery/*@START_MENU_TOKEN@*/.buttons["Continue"]/*[[".otherElements[\"Government of British Columbia\"].buttons[\"Continue\"]",".buttons[\"Continue\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
}
