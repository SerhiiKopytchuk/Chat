//
//  ChatUITests.swift
//  ChatUITests
//
//  Created by Serhii Kopytchuk on 20.07.2022.
//

import XCTest

class ChatUITests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//
//        // In UI tests it is usually best to stop immediately when a failure occurs.
//        continueAfterFailure = false
//
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    var channelName = "testChannel"
    var channelDescription = "testChannelDescription"

    func test01CreatingChannel() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["List"].tap()
        sleep(1)

        app.staticTexts["Create channel"].tap()
        sleep(1)

        app.textFields["Enter name of your channel"].tap()
        app.textFields["Enter name of your channel"].typeText(channelName)
        app.textFields["Describe your channel"].tap()
        app.textFields["Describe your channel"].typeText(channelDescription)

        app.buttons["Public"].tap()
        app.buttons["Create channel"].tap()
        sleep(1)

        app.buttons["fibrechannel"].tap()

        XCTAssert(app.cells.staticTexts[channelName].exists)
    }

    func test02SubscribeAnnaToChannel() throws {

        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()

        app.tables.cells.staticTexts[channelName].tap()
        sleep(1)

        app.staticTexts[channelName].tap()
        sleep(1)

        app.images["Add"].tap()
        app.textFields["Add users"].tap()
        app.textFields["Add users"].typeText("A")

        app.tables.cells["Account, Anna, Add, anna@gmail.com"]
            .children(matching: .other).element(boundBy: 0)
            .children(matching: .other)
            .images["Add"].tap()

        app.buttons["apply"].tap()

        app.images["Remove"].tap()

        XCTAssert(app.cells.staticTexts["Anna"].exists)
    }

    func test03UnsubscribeAnnaFromChannel() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()
        sleep(1)

        app.tables.cells.staticTexts[channelName].tap()
        sleep(1)

        app.staticTexts[channelName].tap()
        sleep(1)

        let subscribersCount = app.staticTexts["Subscribers"]

        app.images["Remove"].tap()

        app.tables.cells["Account, Anna, Remove, anna@gmail.com"]
            .children(matching: .other).element(boundBy: 0)
            .children(matching: .other)
            .images["Remove"].tap()

        app.buttons["Back"].tap()
        sleep(1)

        print(subscribersCount)
        let subscribersCountAfter = app.staticTexts["Subscribers"]
        XCTAssert(subscribersCount != subscribersCountAfter)
    }

    func test04DeletingChannel() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()

        app.tables.cells.staticTexts[channelName].tap()
        sleep(1)

        app.staticTexts[channelName].tap()
        sleep(1)

        app.images["Close"].tap()

        app.buttons["Delete"].tap()
        sleep(1)

        XCTAssert(!app.cells.staticTexts[channelName].exists)
    }

    func test05CreateSeveralChannels() {
        let app = XCUIApplication()
        app.launch()

        createChannel(app: app, name: "firstChannel", description: "firstChannelDescription")
        createChannel(app: app, name: "secondChannel", description: "secondChannelDescription")
        createChannel(app: app, name: "thirdChannel", description: "thirdChannelDescription")

    }

    func createChannel(app:XCUIApplication, name: String, description: String) {

        app.buttons["List"].tap()
        sleep(1)

        app.staticTexts["Create channel"].tap()
        sleep(1)

        app.textFields["Enter name of your channel"].tap()
        app.textFields["Enter name of your channel"].typeText(name)
        app.textFields["Describe your channel"].tap()
        app.textFields["Describe your channel"].typeText(description)

        app.buttons["Public"].tap()
        app.buttons["Create channel"].tap()
        sleep(1)
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
