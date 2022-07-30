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
    let channelNameEdited = "testChannelEdited"
    let channelDescriptionEdited = "testChannelDescriptionEdited"
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

        app.buttons["Create"].tap()
        sleep(1)

        app.buttons["fibrechannel"].tap()

        XCTAssert(app.scrollViews.staticTexts[channelName].exists)
    }

    func test02SubscribeAnnaToChannel() throws {

        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()

        app.scrollViews.staticTexts[channelName].tap()
        sleep(1)

        app.staticTexts[channelName].tap()
        sleep(1)

        app.images["Add"].tap()
        app.textFields["Search users"].tap()
        app.textFields["Search users"].typeText("Anna")

        app.scrollViews.otherElements.images["Add"].tap()

        app.buttons["apply"].tap()

        app.images["Remove"].tap()

        XCTAssert(app.scrollViews.staticTexts["Anna"].exists)
    }

    func test03UnsubscribeAnnaFromChannel() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()
        sleep(1)

        app.scrollViews.staticTexts[channelName].tap()
        sleep(1)

        app.staticTexts[channelName].tap()
        sleep(1)

        let subscribersCount = app.staticTexts["Subscribers"]

        app.images["Remove"].tap()

        app.scrollViews.otherElements.images["Remove"].tap()

        app.buttons["arrow.backward.circle.fill"].tap()
        sleep(1)

        print(subscribersCount)
        let subscribersCountAfter = app.staticTexts["Subscribers"]
        XCTAssert(subscribersCount != subscribersCountAfter)
    }

    func test04EditingChannel() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()

        app.scrollViews.staticTexts[channelName].tap()
        sleep(1)

        app.staticTexts[channelName].tap()
        sleep(1)

        app.images["Edit"].tap()
        sleep(1)

        app.textFields["Enter channel name"].tap()
        app.textFields["Enter channel name"].typeText("Edited")

        app.textFields["Type channel description"].tap()
        app.textFields["Type channel description"].typeText("Edited")

        app.buttons["Selected"].tap()

        let editedChannelName = app.staticTexts["\(channelName)Edited"]
        let editedChannelDescription = app.staticTexts["\(channelDescription)Edited"]

        let editedChannelNameExpectation = XCTNSPredicateExpectation(predicate: existsPredicate,
                                                                     object: editedChannelName)
        let editedChannelDescriptionExpectation = XCTNSPredicateExpectation(predicate: existsPredicate,
                                                                            object: editedChannelDescription)

        wait(for: [editedChannelNameExpectation, editedChannelDescriptionExpectation], timeout: 5)
    }

    func test05DeletingChannel() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()

        app.scrollViews.staticTexts[channelNameEdited].tap()
        sleep(1)

        app.staticTexts[channelNameEdited].tap()
        sleep(1)

        app.images["Close"].tap()

        app.buttons["Delete"].tap()
        sleep(1)

        XCTAssert(!app.scrollViews.staticTexts[channelNameEdited].exists)
    }

    func test06CreateSeveralChannels() throws {
        let app = XCUIApplication()
        app.launch()

        createChannel(app: app, name: "firstChannel", description: "firstChannelDescription")
        createChannel(app: app, name: "secondChannel", description: "secondChannelDescription")
        createChannel(app: app, name: "thirdChannel", description: "thirdChannelDescription")

        app.buttons["fibrechannel"].tap()

        let firstChannelCell = app.scrollViews.staticTexts["firstChannel"]
        let secondChannelCell = app.scrollViews.staticTexts["secondChannel"]
        let thirdChannelCell = app.scrollViews.staticTexts["thirdChannel"]

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

        app.buttons["Create"].tap()
        sleep(1)
    }

    func test07DeleteSeveralChannels() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()

        deleteChannel(app: app, name: "firstChannelDescription")
        deleteChannel(app: app, name: "secondChannelDescription")
        deleteChannel(app: app, name: "thirdChannelDescription")

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
        app.scrollViews.staticTexts["\(name)"].press(forDuration: 1)
        app.buttons["delete channel"].tap()
    }

    func test08StartChatWithAnna() throws {

        let app = XCUIApplication()
        app.launch()

        app.buttons["List"].tap()
        sleep(1)

        app.buttons["Search"].tap()
        sleep(1)

        app.textFields["Enter user name"].tap()
        app.textFields["Enter user name"].typeText("A")

        app.scrollViews.staticTexts["Anna"].tap()
            sleep(1)
        app.buttons["Start Chat"].tap()
        app.buttons["arrow.backward.circle.fill"].tap()
        app.buttons["arrow.backward.circle.fill"].tap()

        let chatCell = app.scrollViews.staticTexts["Anna"]
        let chatAnnaExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: chatCell)

        wait(for: [chatAnnaExpectation], timeout: 5)
    }

    func test09DeleteChatWithAnna() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(1)

        app.scrollViews.staticTexts["Anna"].press(forDuration: 1)

        app.buttons["remove chat"].tap()
        sleep(1)

        let chatCell = app.scrollViews.staticTexts["Anna"]

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
