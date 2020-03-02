//
//  CurrencyConverterUITests.swift
//  CurrencyConverterUITests
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import XCTest

class CurrencyConverterUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCurrencyListSave() {
        //MARK: Initialization
        let app = XCUIApplication()
        app.launchArguments += ["UI-Testing"]
        app.launch()

        let tablesQuery = app.tables
        let currencyNavBar = app.navBar(title: "Currency converter")
        let editNavBar = app.navBar(title: "Edit currency list")
        let editButton = currencyNavBar.buttons["Edit"]
        let saveButton = editNavBar.buttons["SAVE"]
        let backButton = editNavBar.buttons["Currency converter"]
        let audStaticText = tablesQuery.staticTexts["AUD"]
        let cadStaticText = tablesQuery.staticTexts["CAD"]
        let dkkStaticText = tablesQuery.staticTexts["DKK"]
        let eurStaticText = tablesQuery.staticTexts["EUR"]
        let gbpStaticText = tablesQuery.staticTexts["GBP"]
        let usdStaticText = tablesQuery.staticTexts["USD"]

        func checkCells(audCadDkkExists: Bool) {
            XCTAssertTrue(eurStaticText.exists)
            XCTAssertTrue(gbpStaticText.exists)
            XCTAssertTrue(usdStaticText.exists)
            if audCadDkkExists {
                XCTAssertTrue(audStaticText.exists)
                XCTAssertTrue(cadStaticText.exists)
                XCTAssertTrue(dkkStaticText.exists)
            } else {
                XCTAssertFalse(audStaticText.exists)
                XCTAssertFalse(cadStaticText.exists)
                XCTAssertFalse(dkkStaticText.exists)
            }
        }

        // MARK: Add new elements to list
        XCTAssertTrue(currencyNavBar.exists(timeout: 5))
        XCTAssertTrue(editButton.exists(timeout: 5))
        checkCells(audCadDkkExists: false)
        editButton.tap()
        XCTAssertTrue(editNavBar.exists(timeout: 5))
        XCTAssertTrue(saveButton.exists(timeout: 5))
        checkCells(audCadDkkExists: true)
        audStaticText.tap()
        cadStaticText.tap()
        dkkStaticText.tap()
        saveButton.tap()
        XCTAssertTrue(currencyNavBar.exists(timeout: 5))
        checkCells(audCadDkkExists: true)
        // MARK: Remove elements from list
        editButton.tap()
        XCTAssertTrue(editNavBar.exists(timeout: 5))
        audStaticText.tap()
        cadStaticText.tap()
        dkkStaticText.tap()
        saveButton.tap()
        XCTAssertTrue(currencyNavBar.exists(timeout: 5))
        checkCells(audCadDkkExists: false)
        // MARK: Check for no save scenario
        editButton.tap()
        XCTAssertTrue(editNavBar.exists(timeout: 5))
        audStaticText.tap()
        cadStaticText.tap()
        dkkStaticText.tap()
        XCTAssertTrue(backButton.exists(timeout: 5))
        backButton.tap()
        XCTAssertTrue(currencyNavBar.exists(timeout: 5))
        checkCells(audCadDkkExists: false)
        // MARK: Check cell movement
        XCTAssertEqual(tablesQuery.cells.element(boundBy: 0).label, "EUR")
        usdStaticText.tap()
        XCTAssertEqual(tablesQuery.cells.element(boundBy: 0).label, "USD")
        // MARK: Check value changes and cell updates
        tablesQuery.cells.element(boundBy: 0).textFields.element(boundBy: 0).clearAndEnterText(text: "50")
        let cell1Label = tablesQuery.cells.element(boundBy: 1).textFields.element(boundBy: 0).value
        let cell2Label = tablesQuery.cells.element(boundBy: 2).textFields.element(boundBy: 0).value
        guard let value1 = cell1Label as? String, let value2 = cell2Label as? String else {
            XCTFail()
            return
        }
        let cell1Value = Double(value1) ?? 0.0
        let cell2Value = Double(value2) ?? 0.0
        let rate1 = Double(tablesQuery.cells.element(boundBy: 1).staticTexts.element(boundBy: 1).label) ?? 0.0
        let rate2 = Double(tablesQuery.cells.element(boundBy: 2).staticTexts.element(boundBy: 1).label) ?? 0.0
        XCTAssertNotEqual(cell1Value, 0.0)
        XCTAssertNotEqual(cell2Value, 0.0)
        XCTAssertEqual(round(cell1Value), round(50 * rate1))
        XCTAssertEqual(round(cell2Value), round(50 * rate2))
    }
}

extension XCUIElement {
    func exists(timeout: TimeInterval) -> Bool {
        return self.waitForExistence(timeout: timeout)
    }

    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }
}

extension XCUIApplication {
    func navBar(title: String) -> XCUIElement {
        self.navigationBars[title]
    }
}
