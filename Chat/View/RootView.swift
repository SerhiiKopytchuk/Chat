//
//  ContentView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.05.2022.
//

import SwiftUI
import Firebase
// Apple HIG
// Apple Human Interface Guidelines

// SF Symbols
struct RootView: View {

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var editChannelViewModel: EditChannelViewModel

    var body: some View {

        NavigationView {
            VStack {
                if viewModel.signedIn {
                    MainView()
                        .environmentObject(viewModel)
                        .environmentObject(messagingViewModel)
                        .environmentObject(chattingViewModel)
                        .environmentObject(channelViewModel)
                        .environmentObject(channelMessagingViewModel)
                        .environmentObject(editChannelViewModel)
                        .navigationBarTitleDisplayMode(.inline)

                } else {
                    SignUpView()
                        .environmentObject(chattingViewModel)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(.stack)
        .accentColor(.orange)
        .onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}
