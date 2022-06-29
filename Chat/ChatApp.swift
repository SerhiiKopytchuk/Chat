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

            RootView()
                .onAppear {
                        viewModel.getCurrentUser { user in
                            chattingViewModel.user = user
                            chattingViewModel.getChats()
                            channelViewModel.currentUser = user
                            channelViewModel.getChannels()
                        }
                }
                .environmentObject(viewModel)
                .environmentObject(messagingViewModel)
                .environmentObject(chattingViewModel)
                .environmentObject(channelViewModel)
                .environmentObject(channelMessagingViewModel)
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
