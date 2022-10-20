//
//  ChatApp.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.05.2022.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct ChatApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            let viewModel = UserViewModel()
            let messagingViewModel = MessagingViewModel()
            let chattingViewModel = ChattingViewModel()
            let channelViewModel = ChannelViewModel()
            let channelMessagingViewModel = ChannelMessagingViewModel()
            let editChannelViewModel = EditChannelViewModel()
            let imageViewModel = ImageViewModel()
            let presenceViewModel = PresenceViewModel()

            RootView()
                .onAppear {
                        viewModel.getCurrentUser { user in
                            viewModel.updateCurrentUser(userId: user.id)
                            chattingViewModel.currentUser = user
                            chattingViewModel.getChats(fromUpdate: false)
                            channelViewModel.currentUser = user
                            channelViewModel.getChannels(fromUpdate: false)

                            if viewModel.isSignedIn {
                                presenceViewModel.startSetup(user: viewModel.currentUser)
                            }
                        }
                }
                .environmentObject(viewModel)
                .environmentObject(messagingViewModel)
                .environmentObject(chattingViewModel)
                .environmentObject(channelViewModel)
                .environmentObject(channelMessagingViewModel)
                .environmentObject(editChannelViewModel)
                .environmentObject(imageViewModel)
                .environmentObject(presenceViewModel)
        }

    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    // swiftlint:disable:next line_length
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }

    // swiftlint:disable:next line_length
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
