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

    let channelName = "testChannel"
    let channelDescription = "testChannelDescription"
    let notExistsPredicate = NSPredicate(format: "exists == false")
    let existsPredicate = NSPredicate(format: "exists == true")

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

    func test05CreateSeveralChannels() throws {
        let app = XCUIApplication()
        app.launch()

        createChannel(app: app, name: "firstChannel", description: "firstChannelDescription")
        createChannel(app: app, name: "secondChannel", description: "secondChannelDescription")
        createChannel(app: app, name: "thirdChannel", description: "thirdChannelDescription")

        app.buttons["fibrechannel"].tap()

        let firstChannelCell = app.cells.staticTexts["firstChannel"]
        let secondChannelCell = app.cells.staticTexts["secondChannel"]
        let thirdChannelCell = app.cells.staticTexts["thirdChannel"]

        let firstChannelExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: firstChannelCell)
        let secondChannelExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: secondChannelCell)
        let thirdChannelExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: thirdChannelCell)

        wait(for: [firstChannelExpectation, secondChannelExpectation, thirdChannelExpectation], timeout: 5)
    }

    private func createChannel(app: XCUIApplication, name: String, description: String) {

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

    func test06DeleteSeveralChannels() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()

        deleteChannel(app: app, name: "firstChannel")
        deleteChannel(app: app, name: "secondChannel")
        deleteChannel(app: app, name: "thirdChannel")

        let firstChannelCell = app.cells.staticTexts["firstChannel"]
        let secondChannelCell = app.cells.staticTexts["secondChannel"]
        let thirdChannelCell = app.cells.staticTexts["thirdChannel"]

        let firstChannelExpectation = XCTNSPredicateExpectation(predicate: notExistsPredicate,
                                                                object: firstChannelCell)

        let secondChannelExpectation = XCTNSPredicateExpectation(predicate: notExistsPredicate,
                                                                 object: secondChannelCell)

        let thirdChannelExpectation = XCTNSPredicateExpectation(predicate: notExistsPredicate,
                                                                object: thirdChannelCell)

        wait(for: [firstChannelExpectation, secondChannelExpectation, thirdChannelExpectation], timeout: 5)
    }

    private func deleteChannel(app: XCUIApplication, name: String) {
        app.tables.cells.staticTexts[name].press(forDuration: 1)
        app.buttons["delete channel"].tap()
    }

    func test07StartChatWithAnna() throws {

        let app = XCUIApplication()
        app.launch()

        app.buttons["List"].tap()
        sleep(1)

        app.buttons["Search"].tap()
        sleep(1)

        app.textFields["Search users"].tap()
        app.textFields["Search users"].typeText("A")

        app.tables.staticTexts["Anna"].tap()
            sleep(1)
        app.buttons["Start Chat"].tap()
        app.buttons["Search"].tap()
        app.buttons["Back"].tap()

        let chatCell = app.tables.staticTexts["Anna"]
        let chatAnnaExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: chatCell)

        wait(for: [chatAnnaExpectation], timeout: 5)
    }

    func test07DeleteChatWithAnna() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(1)

        app.tables.staticTexts["Anna"].press(forDuration: 1)

        app.buttons["remove chat"].tap()
        sleep(1)

        let chatCell = app.tables.staticTexts["Anna"]

        let chatAnnaExpectation = XCTNSPredicateExpectation(predicate: notExistsPredicate, object: chatCell)

        wait(for: [chatAnnaExpectation], timeout: 5)
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
