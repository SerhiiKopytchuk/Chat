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

    // MARK: - vars
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var editChannelViewModel: EditChannelViewModel
    @EnvironmentObject private var imageViewModel: ImageViewModel

    // MARK: - body
    var body: some View {

        NavigationStack {
            VStack {
                if viewModel.signedIn {
                    MainView()
                } else {
                    SignUpView()
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}
