import XCTest

/// Verify the mission hierarchy, visible spoilers, native search, themes, and map presentation.
final class JourneyUITests: XCTestCase {
    @MainActor
    func testMissionOrganizationAndVisibleSpoilers() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.navigationBars["Chapters"].waitForExistence(timeout: 10))
        capture("Chapters — light", app: app)

        app.staticTexts["Kuwaq Yaku"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Where the Twins Confer"].waitForExistence(timeout: 5))
        capture("Kuwaq Yaku — actual story missions", app: app)
        app.staticTexts["Path of the Living"].tap()
        XCTAssertTrue(app.staticTexts["0 of 2 chapter goals"].waitForExistence(timeout: 5))
        app.buttons["Set as current"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Current"].exists)
        XCTAssertTrue(app.staticTexts["First Blood"].exists)
        XCTAssertTrue(app.staticTexts["Fire of Life"].exists)
        capture("Path of the Living — chapter and ongoing goals", app: app)
        app.staticTexts["Fire of Life"].tap()
        XCTAssertTrue(app.staticTexts["Spoiler"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Fire of Life"].exists)
        XCTAssertFalse(app.buttons["Reveal objective"].exists)
        capture("Spoiler objective — always visible", app: app)

        app.tabBars.buttons["Search"].tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("The Chosen One")
        if app.keyboards.buttons["Search"].exists { app.keyboards.buttons["Search"].tap() }
        XCTAssertTrue(app.staticTexts["The Chosen One"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Recover Ix Chel’s Silver Box."].exists)
        capture("Search finds spoiler titles and requirements", app: app)
    }

    @MainActor
    func testAppearanceMissableFilterAndMap() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        app.buttons["Settings"].tap()
        let appearance = app.segmentedControls.firstMatch
        XCTAssertTrue(appearance.waitForExistence(timeout: 5))
        appearance.buttons["Light"].tap()
        XCTAssertTrue(appearance.buttons["Light"].isSelected)
        appearance.buttons["Dark"].tap()
        XCTAssertTrue(appearance.buttons["Dark"].isSelected)
        app.buttons["Done"].tap()
        capture("Chapters — dark", app: app)

        app.tabBars.buttons["Search"].tap()
        if app.keyboards.buttons["Search"].exists { app.keyboards.buttons["Search"].tap() }
        app.segmentedControls["catalogScope"].buttons["Missable"].tap()
        XCTAssertTrue(app.staticTexts["14 achievements"].waitForExistence(timeout: 5))
        capture("Missable catalog — dark", app: app)

        // Native search collapses the other tabs into the leading chapter button.
        app.tabBars.buttons["Chapters"].tap()
        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.buttons["Cozumel map"].waitForExistence(timeout: 5))
        capture("Map — dark", app: app)
        app.buttons["Cozumel map"].tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 10))
        app.buttons["Close"].tap()
    }

    @MainActor
    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
