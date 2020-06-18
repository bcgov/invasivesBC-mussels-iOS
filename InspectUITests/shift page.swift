//
//  shift page.swift
//  InspectUITests
//
//  Created by Amir Shayegh on 2020-06-18.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import XCTest

class shift_page: XCTestCase {

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

    func testShiftCreation() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()

        let loginButton = app.buttons["Login with IDIR"]
        if loginButton.exists {
            beginWithLogin()
        } else {
            createShift()
        }
    }
    
    func beginWithLogin() {
        let app = XCUIApplication()
        let loginButton = app.buttons["Login with IDIR"]
        loginButton.tap()
        
        let webViewsQuery = app.webViews.webViews.webViews
        let governmentOfBritishColumbiaElement = webViewsQuery.otherElements["Government of British Columbia"]
        governmentOfBritishColumbiaElement.children(matching: .textField).element.tap()
        governmentOfBritishColumbiaElement.children(matching: .textField).element.typeText("istest3")
         governmentOfBritishColumbiaElement.children(matching: .secureTextField).element.tap()
        governmentOfBritishColumbiaElement.children(matching: .secureTextField).element.typeText("Qwer12343")
        webViewsQuery/*@START_MENU_TOKEN@*/.buttons["Continue"]/*[[".otherElements[\"Government of British Columbia\"].buttons[\"Continue\"]",".buttons[\"Continue\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        createShift()
    }
    
    func createShift() {
        let app = XCUIApplication()
        let exists = NSPredicate(format: "exists == 1")
        let newShiftButton = app.buttons["Add New Shift"]
        expectation(for: exists, evaluatedWith: newShiftButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(app.buttons["Add New Shift"].exists, "New Shift Button Exists")
        app.buttons["Add New Shift"].tap()
        if app.buttons["Start Now"].exists {
            fillShiftModal()
            fillShiftPageWithoutInspections()
        } else {
            fillShiftPageWithoutInspections()
        }
    }
    
    func fillShiftPageWithoutInspections() {
        let app = XCUIApplication()
        let newShiftButton = app.buttons["Add New Shift"]
        let exists = NSPredicate(format: "exists == 1")
        
        // Check page is displayed
        XCTAssertTrue( app.navigationBars["Shift Overview"].buttons["Submit"].exists, "Shift page opened.")
        
        // Select station
        let station = app/*@START_MENU_TOKEN@*/.collectionViews.textFields["station"]/*[[".otherElements[\"newShiftModal\"].collectionViews",".cells.textFields[\"station\"]",".textFields[\"station\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(station.exists, "stations dropdown button Exists")
        station.tap()
        app.popovers.tables/*@START_MENU_TOKEN@*/.staticTexts["Golden"]/*[[".cells.staticTexts[\"Golden\"]",".staticTexts[\"Golden\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        // Select shift start time
        .tap()
        let shiftStartTime = app.collectionViews.textFields["shiftstarttime"]
        XCTAssertTrue(shiftStartTime.exists, "shift Start Time button Exists")
        shiftStartTime.tap()
        app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Scroll
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Shift Start").element.swipeUp()
        
        // Select shift end time
        app.collectionViews/*@START_MENU_TOKEN@*/.collectionViews.textFields["shiftendtime"]/*[[".cells.collectionViews",".cells.textFields[\"shiftendtime\"]",".textFields[\"shiftendtime\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Submit
        app.navigationBars["Shift Overview"].buttons["Submit"].tap()
        //        app.children(matching: .window).element(boundBy: 0).tap()
        app.buttons["Yes"].tap()
        
        // Check that we are back at the home page
        expectation(for: exists, evaluatedWith: newShiftButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(app.buttons["Add New Shift"].exists, "Back to home page.")
    }
    
    func fillShiftModal() {
        let app = XCUIApplication()
        
        // Check modal is displayed
        XCTAssertTrue(app.buttons["Start Now"].exists, "stations dropdown button Exists")
        
        // Select station
        let station = app/*@START_MENU_TOKEN@*/.collectionViews.textFields["station"]/*[[".otherElements[\"newShiftModal\"].collectionViews",".cells.textFields[\"station\"]",".textFields[\"station\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(station.exists, "stations dropdown button Exists")
        station.tap()
        app.popovers.tables/*@START_MENU_TOKEN@*/.staticTexts["Golden"]/*[[".cells.staticTexts[\"Golden\"]",".staticTexts[\"Golden\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Select shift start time
        let shiftStartTime = app.collectionViews.textFields["shiftstarttime"]
        XCTAssertTrue(shiftStartTime.exists, "shift Start Time button Exists")
        shiftStartTime.tap()
        app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Submit shift
        app.buttons["Start Now"].tap()
    }
    
    func teardown() {
        let app = XCUIApplication()
        if app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists{
            XCUIApplication()/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        app.buttons["person.crop.circle"].tap()
        app.popovers.tables/*@START_MENU_TOKEN@*/.staticTexts["Logout"]/*[[".cells.staticTexts[\"Logout\"]",".staticTexts[\"Logout\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.children(matching: .window).element(boundBy: 0).tap()
    }

}
