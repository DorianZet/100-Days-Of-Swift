//
//  Project39UITests.swift
//  Project39UITests
//
//  Created by Mateusz Zacharski on 30/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import XCTest

class Project39UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testInitialStateIsCorrect() {
        XCUIApplication().activate()
        let table = XCUIApplication().tables // calling '.tables' will return an 'XCUIElementQuery', which in our situation would point to our table.
        XCTAssertEqual(table.cells.count, 7, "There should be 7 rows initially.")
    }
    
    // Writing a test as if a user tapped searched "test" in the search text field:
    func testUserFilteringByString() {
        let app = XCUIApplication()
        app.activate() // activate the app.
        app.buttons["Search"].tap() // tap on the search button.
        
        let filterAlert = app.alerts // point to the filter alert controller.
        let textField = filterAlert.textFields.element // point to the text field in the filter alert controller.
        textField.typeText("test") // type "test" in the text field.
        
        filterAlert.buttons["Filter"].tap() // press "Filter" button in the filter alert controller.
        
        XCTAssertEqual(app.tables.cells.count, 56, "There should be 56 words matching \"test\"") // assure that there are 56 row cells matching word "test".
    }
    
    func testUserFilteringBy1000() {
        let app = XCUIApplication()
        app.activate()
        
        app.buttons["Search"].tap()
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("1000")
        
        filterAlert.buttons["Filter"].tap()
                
        XCTAssertEqual(app.tables.cells.count, 55, "There should be 55 words matching \"1000\"")
    }
    
    func testCancelButtonPressed() {
        let app = XCUIApplication()
        app.activate()
        app.buttons["Search"].tap()
        
        let rowsNumberBeforeCancel = app.tables.cells.count
        
        let filterAlert = app.alerts
        filterAlert.buttons["Cancel"].tap()
        
        let rowsNumberAfterCancel = app.tables.cells.count
        
        XCTAssertEqual(rowsNumberBeforeCancel, rowsNumberAfterCancel, "After pressing the cancel button, number of rows can't be changed.")
    }
    
    
    
}
