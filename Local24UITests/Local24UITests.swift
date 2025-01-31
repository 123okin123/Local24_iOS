//
//  Local24UITests.swift
//  Local24UITests
//
//  Created by Nikolai Kratz on 21.09.15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import XCTest

class Local24UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
 let app = XCUIApplication()
        app.buttons["insert"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Bitte wählen Sie ein Kategorie"].tap()

        tablesQuery.staticTexts["Autos, Fahrzeuge"].tap()
        tablesQuery.staticTexts["Auto"].tap()
        tablesQuery.staticTexts["Audi"].swipeUp()
        tablesQuery.cells.containing(.staticText, identifier:"Cadillac").children(matching: .staticText).matching(identifier: "Cadillac").element(boundBy: 0).tap()
        tablesQuery.staticTexts["Eldorado"].tap()

        
        
        
    }
    
}
