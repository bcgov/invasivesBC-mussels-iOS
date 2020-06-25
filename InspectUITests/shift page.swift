//
//  shift page.swift
//  InspectUITests
//
//  Created by Amir Shayegh on 2020-06-18.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import XCTest

class shift_page: XCTestCase {
    
    let exists = NSPredicate(format: "exists == 1")
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        let app = XCUIApplication()
        // If login page is presented, login
        if app.buttons["Login with IDIR"].exists {
            login()
        }
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func login() {
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
    }
    
    /**
     Tests:
     - Create & submit a shift
     - Create a shift, edit shift & submit
     */
    func testShiftCreation() throws {
        let app = XCUIApplication()
        let newShiftButton = app.buttons["Add New Shift"]
        
        if !shiftExists() {
            createShiftDraft()
        }
        expectation(for: exists, evaluatedWith: newShiftButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        app.buttons["Add New Shift"].tap()
        fillShiftPageWithInspections()
        /*
         if !shiftExists() {
         // 1) Create a shift from start to end
         createAndSubmitShift()
         // 2) Start a shift and go back to home page
         createShiftDraft()
         // 3) Finish shift started in the above step
         createAndSubmitShift()
         // 4) Logout
         teardown()
         } else {
         // 1) Finish Existing shift
         createAndSubmitShift()
         // 2) Create a shift from start to end
         createAndSubmitShift()
         // 4) Logout
         teardown()
         }
         */
                
        
        
//        type-search-waterbodies
        
//        let app = XCUIApplication()
//        app/*@START_MENU_TOKEN@*/.staticTexts["Add New Shift"]/*[[".buttons[\"Add New Shift\"].staticTexts[\"Add New Shift\"]",".staticTexts[\"Add New Shift\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.collectionViews["shiftform"]/*@START_MENU_TOKEN@*/.tables/*[[".cells.tables",".tables"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"4").buttons["Edit"].tap()
//
//        let collectionViewsQuery = app.collectionViews
//        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Watercraft Details"]/*[[".cells.staticTexts[\"Watercraft Details\"]",".staticTexts[\"Watercraft Details\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
//
//        let addPreviousWaterBodyButton = collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["Add Previous Water Body"]/*[[".cells.buttons[\"Add Previous Water Body\"]",".buttons[\"Add Previous Water Body\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        addPreviousWaterBodyButton.tap()
//        addPreviousWaterBodyButton.tap()
        
        
    }
    
    /**
     Check if a shift has been created but not submitted
     */
    func shiftExists() -> Bool {
        let app = XCUIApplication()
        let newShiftButton = app.buttons["Add New Shift"]
        expectation(for: exists, evaluatedWith: newShiftButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(app.buttons["Add New Shift"].exists, "New Shift Button Exists")
        app.buttons["Add New Shift"].tap()
        if app.buttons["Start Now"].exists {
            app.buttons["Cancel"].tap()
            return false
        } else {
            if app.navigationBars["Shift Overview"].exists {
                app.navigationBars["Shift Overview"].buttons["Back"].tap()
            }
            return true
        }
    }
    
    /**
     Create a shift without submitting & navigate to home page
     */
    func createShiftDraft() {
        if shiftExists() {
            return
        }
        let app = XCUIApplication()
        let newShiftButton = app.buttons["Add New Shift"]
        expectation(for: exists, evaluatedWith: newShiftButton, handler: nil)
        waitForExpectations(timeout: 7, handler: nil)
        XCTAssertTrue(app.buttons["Add New Shift"].exists, "New Shift Button Exists")
        app.buttons["Add New Shift"].tap()
        fillShiftModal()
        app.navigationBars["Shift Overview"].buttons["Back"].tap()
    }
    
    /**
     Create or complete a shift & submit
     */
    func createAndSubmitShift() {
        let app = XCUIApplication()
        let newShiftButton = app.buttons["Add New Shift"]
        expectation(for: exists, evaluatedWith: newShiftButton, handler: nil)
        waitForExpectations(timeout: 7, handler: nil)
        XCTAssertTrue(app.buttons["Add New Shift"].exists, "New Shift Button Exists")
        app.buttons["Add New Shift"].tap()
        // Check if we should fill the modal or if we need to complete an existing shift
        if app.buttons["Start Now"].exists {
            fillShiftModal()
            fillShiftPageWithoutInspections()
        } else {
            fillShiftPageWithoutInspections()
        }
    }
    
    /**
     Fill shift data without adding inspections
     */
    func fillShiftPageWithoutInspections() {
        let app = XCUIApplication()
        
        // Check page is displayed
        XCTAssertTrue( app.navigationBars["Shift Overview"].buttons["Submit"].exists, "Shift page opened.")
        
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
        
        // Scroll
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Shift Start").element.swipeUp()
        
        // Select shift end time
        app.collectionViews/*@START_MENU_TOKEN@*/.collectionViews.textFields["shiftendtime"]/*[[".cells.collectionViews",".cells.textFields[\"shiftendtime\"]",".textFields[\"shiftendtime\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Submit
        submitShiftPage()
        
    }
    
    func fillShiftPageWithInspections() {
        let app = XCUIApplication()
        let newShiftButton = app.buttons["Add New Shift"]
        
        // Check page is displayed
        XCTAssertTrue( app.navigationBars["Shift Overview"].buttons["Submit"].exists, "Shift page opened.")
        
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
        
        // Scroll down
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Shift Start").element.swipeUp()
        
        // Select shift end time
        app.collectionViews/*@START_MENU_TOKEN@*/.collectionViews.textFields["shiftendtime"]/*[[".cells.collectionViews",".cells.textFields[\"shiftendtime\"]",".textFields[\"shiftendtime\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Scroll up
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Shift End").element.swipeDown()
        createObservationForPassportHolder()
        
        // Submit
        //        submitShiftPage()
    }
    
    func submitShiftPage() {
        let app = XCUIApplication()
        let newShiftButton = app.buttons["Add New Shift"]
        
        app.navigationBars["Shift Overview"].buttons["Submit"].tap()
        app.buttons["Yes"].tap()
        
        // Check that we are back at the home page
        expectation(for: exists, evaluatedWith: newShiftButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(app.buttons["Add New Shift"].exists, "Back to home page.")
    }
    
    /**
     Fill shift modal data
     */
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
    
    /**
     Logout
     */
    func teardown() {
        let app = XCUIApplication()
        app.buttons["person.crop.circle"].tap()
        app.popovers.tables/*@START_MENU_TOKEN@*/.staticTexts["Logout"]/*[[".cells.staticTexts[\"Logout\"]",".staticTexts[\"Logout\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Yes"].tap()
    }
    
    //MARK: Observation
    
    func createObservationForPassportHolder() {
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        let cellsQuery = collectionViewsQuery.cells.collectionViews.cells
        
        // Tap Add Inspection
        app.collectionViews["shiftform"]/*@START_MENU_TOKEN@*/.buttons["Add Inspection"]/*[[".cells.buttons[\"Add Inspection\"]",".buttons[\"Add Inspection\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Select is Passport Holder
        cellsQuery.otherElements.containing(.staticText, identifier:"Is this a Passport Holder?").children(matching: .other).element.children(matching: .other).element(boundBy: 0).tap()
        
        // Type passport number
        let passportField = app.collectionViews/*@START_MENU_TOKEN@*/.collectionViews.textFields["Passport Number"]/*[[".cells.collectionViews",".cells.textFields[\"Passport Number\"]",".textFields[\"Passport Number\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
//        XCTAssertTrue(passportField.exists, "Passport field Exists")
        passportField.tap()
        passportField.typeText("BC123456")
        
        
        // Select Launched Outside BC to trigger full form
        let lancuedOutsideBC = app.collectionViews/*@START_MENU_TOKEN@*/.collectionViews.switches["launchedoutsidebc/abinthelast30days?"]/*[[".cells.collectionViews",".cells[\"launchedoutsidebc\/abinthelast30days?cell\"].switches[\"launchedoutsidebc\/abinthelast30days?\"]",".switches[\"launchedoutsidebc\/abinthelast30days?\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        expectation(for: exists, evaluatedWith: lancuedOutsideBC, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        lancuedOutsideBC.swipeRight()
        
        fillFullInspection()
        
    }
    
    func fillFullInspection() {
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        
        // Enter some basic info
        collectionViewsQuery/*@START_MENU_TOKEN@*/.collectionViews.textFields["province/state of boat residence"]/*[[".cells.collectionViews",".cells.textFields[\"province\/state of boat residence\"]",".textFields[\"province\/state of boat residence\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app.popovers.tables/*@START_MENU_TOKEN@*/.staticTexts["British Columbia - CAN"]/*[[".cells.staticTexts[\"British Columbia - CAN\"]",".staticTexts[\"British Columbia - CAN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Scroll down
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Basic Information"]/*[[".cells.staticTexts[\"Basic Information\"]",".staticTexts[\"Basic Information\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        
        // Add number of people in party
        let incrementButton = collectionViewsQuery.cells.collectionViews.cells.otherElements.containing(.staticText, identifier:"Number of people in the party").steppers.buttons["Increment"]
        incrementButton.tap()
        incrementButton.tap()
        
        // Scroll down
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Watercraft Details"]/*[[".cells.staticTexts[\"Watercraft Details\"]",".staticTexts[\"Watercraft Details\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        
        // Add Previous waterbody
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Add Previous Water Body"]/*[[".cells.buttons[\"Add Previous Water Body\"]",".buttons[\"Add Previous Water Body\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Search
        
        let searchBarElement = app.textFields["type-search-waterbodies"]
//        searchBarElement.tap()
        XCTAssertTrue(searchBarElement.exists, "Search bar Exists")
        searchBarElement.tap()
        searchBarElement.firstMatch.typeText("sylvan")
//        let searchfield = app.otherElements["search-waterbodies"].firstMatch
//        searchfield.tap()
//        searchfield.typeText("sylvan")
        
        app/*@START_MENU_TOKEN@*/.tables["waterbodies"].staticTexts["Sylvan Lake, AB, CAN (Sylvan Lake)"]/*[[".otherElements[\"waterbodypicker\"].tables[\"waterbodies\"]",".cells.staticTexts[\"Sylvan Lake, AB, CAN (Sylvan Lake)\"]",".staticTexts[\"Sylvan Lake, AB, CAN (Sylvan Lake)\"]",".tables[\"waterbodies\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.tables["waterbodies"].staticTexts["Duck Lake, AB, CAN (Sylvan Glen)"]/*[[".otherElements[\"waterbodypicker\"].tables[\"waterbodies\"]",".cells.staticTexts[\"Duck Lake, AB, CAN (Sylvan Glen)\"]",".staticTexts[\"Duck Lake, AB, CAN (Sylvan Glen)\"]",".tables[\"waterbodies\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.collectionViews["selectedvalues"]/*[[".otherElements[\"waterbodypicker\"].collectionViews[\"selectedvalues\"]",".collectionViews[\"selectedvalues\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .cell).element(boundBy: 1).buttons["Close"].tap()
        
        // DELETE
        let newShiftButton = app.buttons["Add New Shift"]
        expectation(for: exists, evaluatedWith: newShiftButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
