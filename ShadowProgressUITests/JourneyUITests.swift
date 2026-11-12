import XCTest

/// Exercise the new navigation and themes against a separate test journal.
final class JourneyUITests: XCTestCase {
    @MainActor
    func testChapterSelectionAndAtlas() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.navigationBars["Expedition"].waitForExistence(timeout: 10))
        capture("Expedition — light", app: app)

        app.tabBars.buttons["Journey"].tap()
        app.staticTexts["Kuwaq Yaku"].firstMatch.tap()
        let current = app.buttons["I’m at this chapter"]
        XCTAssertTrue(current.waitForExistence(timeout: 5))
        current.tap()
        XCTAssertTrue(app.buttons["Your current checkpoint"].exists)
        capture("Chapter plan — Kuwaq Yaku", app: app)

        app.tabBars.buttons["Atlas"].tap()
        XCTAssertTrue(app.buttons["Open detailed game map"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Kuwaq Yaku"].firstMatch.exists)
        capture("Atlas — light", app: app)
        app.buttons["Open detailed game map"].tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 10))
        capture("Detailed map — publisher viewer", app: app)
        app.buttons["Close"].tap()
    }

    @MainActor
    func testAppearanceAndMissableFilter() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        app.buttons["Field Kit"].tap()
        let appearance = app.segmentedControls.firstMatch
        XCTAssertTrue(appearance.waitForExistence(timeout: 5))
        appearance.buttons["Light"].tap()
        XCTAssertTrue(appearance.buttons["Light"].isSelected)
        appearance.buttons["Dark"].tap()
        XCTAssertTrue(appearance.buttons["Dark"].isSelected)
        capture("Field Kit — dark", app: app)
        app.buttons["Done"].tap()
        capture("Expedition — dark", app: app)

        app.tabBars.buttons["Achievements"].tap()
        app.buttons["achievementFilter"].tap()
        app.buttons["Missable · unfinished"].tap()
        XCTAssertTrue(app.staticTexts["14 objectives"].waitForExistence(timeout: 5))
        capture("Missable achievements — dark", app: app)
    }

    @MainActor
    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
