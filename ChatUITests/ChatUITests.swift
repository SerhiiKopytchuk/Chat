//
//  ChatUITests.swift
//  ChatUITests
//
//  Created by Serhii Kopytchuk on 20.07.2022.
//

import XCTest
import Foundation
import SwiftUI

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

    let channelName = "Channel(Test)"
    let channelDescription = "ChannelDescription(Test)"
    let channelNameEdited = "ChannelEdited(Test)"
    let channelDescriptionEdited = "testChannelDescriptionEdited(Test)"

    // MARK: predicates
    let notExistsPredicate = NSPredicate(format: "exists == false")
    let existsPredicate = NSPredicate(format: "exists == true")

    // MARK: firstAccount
    let firstUserName = "FirstUser"
    let firstUserEmail = "firstUser@gmail.com"
    let firstUserPassword = "asdfjkl;"

    // MARK: secondAccount
    let secondUserName = "SecondUser"
    let secondUserEmail = "secondUser@gmail.com"
    let secondUserPassword = "asdfjkl;"

    func test001SignUpSecondUserAccount () throws {
        let app = XCUIApplication()
        app.launch()

        let chatsLabel = app.staticTexts["Chats"]

        if chatsLabel.exists {
            logOut(app: app)
        }

        app.textFields["Full Name"].tap()
        app.textFields["Full Name"].typeText(secondUserName)

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(secondUserEmail)

        app.buttons["first eye"].tap()
        app.buttons["second eye"].tap()

        app.textFields["Password"].tap()
        app.textFields["Password"].typeText(secondUserPassword)

        app.textFields["Re-enter"].tap()
        app.textFields["Re-enter"].typeText(secondUserPassword)

        app.buttons["Create Account"].tap()
        sleep(1)

        if app.buttons["Close"].exists {

            app.buttons["Close"].tap()
            app.buttons["return"].tap()
            app.buttons["Sign In"].tap()

            app.textFields["Email"].tap()
            app.textFields["Email"].typeText(secondUserEmail)

            app.secureTextFields["Password"].tap()
            app.secureTextFields["Password"].typeText(secondUserPassword)

            app.buttons["Sign in"].tap()

        }

        let chatLabelExist = XCTNSPredicateExpectation(predicate: existsPredicate,
                                      object: chatsLabel)
        wait(for: [chatLabelExist], timeout: 5)

    }

    func test002SignUpFirstUserAccount () throws {
        let app = XCUIApplication()
        app.launch()

        let chatsLabel = app.staticTexts["Chats"]

        if chatsLabel.exists {
            logOut(app: app)
        }

        app.textFields["Full Name"].tap()
        app.textFields["Full Name"].typeText(firstUserName)

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(firstUserEmail)

        app.buttons["first eye"].tap()
        app.buttons["second eye"].tap()

        app.textFields["Password"].tap()
        app.textFields["Password"].typeText(firstUserPassword)

        app.textFields["Re-enter"].tap()
        app.textFields["Re-enter"].typeText(firstUserPassword)

        app.buttons["Create Account"].tap()
        sleep(1)

        if app.buttons["Close"].exists {

            app.buttons["Close"].tap()
            app.buttons["return"].tap()
            app.buttons["Sign In"].tap()

            app.textFields["Email"].tap()
            app.textFields["Email"].typeText(firstUserEmail)

            app.secureTextFields["Password"].tap()
            app.secureTextFields["Password"].typeText(firstUserPassword)

            app.buttons["Sign in"].tap()

        }

        let chatLabelExist = XCTNSPredicateExpectation(predicate: existsPredicate,
                                      object: chatsLabel)
        wait(for: [chatLabelExist], timeout: 5)

    }

    func test003CreateChannel() throws {
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
        app.buttons["return"].tap()

        app.buttons["Create"].tap()
        sleep(1)

        app.buttons["fibrechannel"].tap()

        XCTAssert(app.scrollViews.staticTexts[channelName].exists)
    }

    func test004SubscribeSecondUserToChannel() throws {

        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()

        app.scrollViews.staticTexts[channelName].tap()
        sleep(1)

        app.staticTexts[channelName].tap()
        sleep(1)

        app.images["Add"].tap()
        app.textFields["Search users"].tap()
        app.textFields["Search users"].typeText(secondUserName)

        app.scrollViews.otherElements.images["Add"].tap()

        app.buttons["apply"].tap()

        app.images["Remove"].tap()

        XCTAssert(app.scrollViews.staticTexts[secondUserName].exists)
    }

    func test005UnsubscribeSecondUserFromChannel() throws {
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

        app.scrollViews.otherElements.buttons["Remove"].tap()

        app.buttons["arrow.backward.circle.fill"].tap()
        sleep(1)

        let subscribersCountAfter = app.staticTexts["Subscribers"]
        XCTAssert(subscribersCount != subscribersCountAfter)
    }

    func test006EditingChannel() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["fibrechannel"].tap()

        app.scrollViews.staticTexts[channelName].tap()
        sleep(1)

        app.staticTexts[channelName].tap()
        sleep(1)

        app.images["Edit"].tap()
        sleep(1)

        app.textFields["Enter channel name"].tap(withNumberOfTaps: 3, numberOfTouches: 1)
        app.textFields["Enter channel name"].typeText(channelNameEdited)

        app.textFields["Type channel description"].tap(withNumberOfTaps: 3, numberOfTouches: 1)
        app.textFields["Type channel description"].typeText(channelDescriptionEdited)

        app.buttons["Selected"].tap()

        let editedChannelName = app.staticTexts[channelNameEdited]
        let editedChannelDescription = app.staticTexts[channelDescriptionEdited]

        let editedChannelNameExpectation = XCTNSPredicateExpectation(predicate: existsPredicate,
                                                                     object: editedChannelName)
        let editedChannelDescriptionExpectation = XCTNSPredicateExpectation(predicate: existsPredicate,
                                                                            object: editedChannelDescription)

        wait(for: [editedChannelNameExpectation, editedChannelDescriptionExpectation], timeout: 5)
    }

    func test007DeletingChannel() throws {
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

    func test008CreateSeveralChannels() throws {
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
        app.buttons["return"].tap()

        app.buttons["Create"].tap()
        sleep(1)
    }

    func test009DeleteSeveralChannels() throws {
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

    func test010StartChatWithSecondUser() throws {

        let app = XCUIApplication()
        app.launch()

        app.buttons["List"].tap()
        sleep(1)

        app.buttons["Search"].tap()
        sleep(1)

        app.textFields["Enter user name"].tap()
        app.textFields["Enter user name"].typeText(secondUserName)

        app.scrollViews.staticTexts[secondUserName].tap()
            sleep(1)
        app.buttons["Start Chat"].tap()
        app.buttons["arrow.backward"].tap()
        app.buttons["arrow.backward.circle.fill"].tap()

        let chatCell = app.scrollViews.staticTexts[secondUserName]
        let chatWithSecondUserExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: chatCell)

        wait(for: [chatWithSecondUserExpectation], timeout: 5)
    }

    func test011SendSecondUserMessage() throws {

        let app = XCUIApplication()
        let message = "Hello \(secondUserName)!"
        app.launch()

        app.scrollViews.staticTexts[secondUserName].tap()
        sleep(1)

        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText(message)

        app.buttons["Send"].tap()

        let sendMessage = app.scrollViews.staticTexts[message]
        let sendMessageExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: sendMessage)

        wait(for: [sendMessageExpectation], timeout: 5)
    }

    func test012SendSecondUserImage() throws {

        let app = XCUIApplication()
        app.launch()

        app.scrollViews.staticTexts[secondUserName].tap()
        sleep(1)

        app.buttons["Photo"].tap()
        app.images["Фото, 30 березня 2018 р., 10:14 пп"].tap()

        let sendImage = app.scrollViews.firstMatch.otherElements["image"]
        let imageExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: sendImage)

        wait(for: [imageExpectation], timeout: 5)
    }

    func test013LogoutTest() throws {

        let app = XCUIApplication()
        app.launch()

        app.buttons["List"].tap()
        sleep(1)

        app.buttons["Logout"].tap()
        sleep(1)

        let signUpText = app.staticTexts["Sign Up"]
        let signUpTextExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: signUpText)

        wait(for: [signUpTextExpectation], timeout: 5)
    }

    func test014SignInToSecondUserAccount() throws {

        let app = XCUIApplication()
        app.launch()

        app.buttons["Sign In"].tap()
        sleep(1)

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(secondUserEmail)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(secondUserPassword)

        app.buttons["Sign in"].tap()
        sleep(1)

        let chatsLabel = app.staticTexts["Chats"]
        let chatsLabelExpectation = XCTNSPredicateExpectation(predicate: existsPredicate,
                                                                         object: chatsLabel)

        wait(for: [chatsLabelExpectation], timeout: 5)
    }

    func test015CheckIfReceiveMessage() throws {

        let app = XCUIApplication()
        let message = "Hello \(secondUserName)!"
        app.launch()

        app.scrollViews.staticTexts[firstUserName].tap()
        sleep(1)

        let sendMessage = app.scrollViews.staticTexts[message]
        let sendMessageExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: sendMessage)

        let sendImage = app.scrollViews.images["image"]
        let imageExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: sendImage)

        wait(for: [sendMessageExpectation, imageExpectation], timeout: 5)
    }

    func test016AddEmojiReactionTest() throws {

        let app = XCUIApplication()
        let message = "Hello \(secondUserName)!"
        app.launch()

        app.scrollViews.staticTexts[firstUserName].tap()
        sleep(1)

        app.scrollViews.staticTexts[message].press(forDuration: 1)
        sleep(1)

        app.staticTexts["🔥"].firstMatch.tap()
        let emojiReaction = app.scrollViews.staticTexts["🔥"]
        let emojiReactionExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: emojiReaction)

        wait(for: [emojiReactionExpectation], timeout: 5)
    }

    func test017SetProfileImage() throws {
        let app = XCUIApplication()
        let firstLetterOfName = String(secondUserName.prefix(1))
        app.launch()

        app.buttons["List"].tap()
        sleep(1)

        app.buttons["Profile"].tap()

        app.buttons[firstLetterOfName].tap()

        app.images["Фото, 30 березня 2018 р., 10:14 пп"].tap()

        app.buttons["arrow.backward.circle.fill"].tap()

        app.buttons["List"].tap()
        sleep(1)

        let notEmptyImage = app.images["notEmptyImage"]

        let imageExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: notEmptyImage)
        wait(for: [imageExpectation], timeout: 5)
    }

    func test018SignInToFirstUserAccount() throws {

        let app = XCUIApplication()
        app.launch()

        logOut(app: app)

        app.buttons["Sign In"].tap()
        sleep(1)

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(firstUserEmail)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(firstUserPassword)

        app.buttons["Sign in"].tap()
        sleep(3)

        app.scrollViews.staticTexts[secondUserName].tap()
        sleep(1)

        let emojiReaction = app.scrollViews.staticTexts["🔥"]
        let emojiReactionExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: emojiReaction)

        wait(for: [emojiReactionExpectation], timeout: 5)
    }

    private func logOut(app: XCUIApplication) {

        app.buttons["List"].tap()
        sleep(1)

        app.buttons["Logout"].tap()
        sleep(1)
    }

    func test19CheckFullScreenHeaderView() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(1)

        app.scrollViews.staticTexts[secondUserName].tap()
        sleep(1)

        app.images["profile image"].firstMatch.tap()

        let text = app.staticTexts[secondUserName]

        let secondUserTextExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: text)

        wait(for: [secondUserTextExpectation], timeout: 5)
    }

    func test020DeleteChatWithSecondUser() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(1)

        app.scrollViews.staticTexts[secondUserName].press(forDuration: 1)

        app.buttons["remove chat"].tap()
        sleep(1)

        let chatCell = app.scrollViews.staticTexts[secondUserName]

        let secondUserChatExpectation = XCTNSPredicateExpectation(predicate: notExistsPredicate, object: chatCell)

        wait(for: [secondUserChatExpectation], timeout: 5)
    }

    func test021CountOfChatsAndChannels() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["List"].tap()
        sleep(1)

        app.buttons["Search"].tap()
        sleep(1)

        app.textFields["Enter user name"].tap()
        app.textFields["Enter user name"].typeText(secondUserName)

        app.scrollViews.staticTexts[secondUserName].tap()
            sleep(1)
        app.buttons["Start Chat"].tap()
        app.buttons["arrow.backward"].tap()
        app.buttons["arrow.backward.circle.fill"].tap()

        app.buttons["List"].tap()
        sleep(1)

        app.staticTexts["Create channel"].tap()
        sleep(1)

        app.textFields["Enter name of your channel"].tap()
        app.textFields["Enter name of your channel"].typeText(channelName)
        app.textFields["Describe your channel"].tap()
        app.textFields["Describe your channel"].typeText(channelDescription)
        app.buttons["return"].tap()

        app.buttons["Create"].tap()

        app.buttons["List"].tap()
        sleep(1)

        let zeroStaticText = app.staticTexts["0"]

        let zeroTextExpectation = XCTNSPredicateExpectation(predicate: notExistsPredicate, object: zeroStaticText)

        wait(for: [zeroTextExpectation], timeout: 5)
    }

    func test022CreateChannelWithImage() throws {

        let app = XCUIApplication()
        app.launch()

        app.buttons["List"].tap()
        sleep(1)

        app.staticTexts["Create channel"].tap()
        sleep(1)

        app.buttons["photo.circle.fill"].tap()
        app.images["Фото, 30 березня 2018 р., 10:14 пп"].tap()

        app.textFields["Enter name of your channel"].tap()
        app.textFields["Enter name of your channel"].typeText("channelWithImage")
        app.textFields["Describe your channel"].tap()
        app.textFields["Describe your channel"].typeText("channelWithImageDescription")
        app.buttons["return"].tap()

        app.buttons["Create"].tap()

        app.buttons["fibrechannel"].tap()

        let image = app.images["UIImage"]

        let imageExpectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: image)

        wait(for: [imageExpectation], timeout: 5)
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
