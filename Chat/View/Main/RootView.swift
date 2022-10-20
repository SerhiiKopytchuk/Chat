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
    @EnvironmentObject private var presenceViewModel: PresenceViewModel
    @Environment(\.scenePhase) var scenePhase

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
            .onChange(of: scenePhase, perform: { phase in
                if phase == .active {
                    viewModel.getCurrentUser { user in
                        presenceViewModel.startSetup(user: user)
                    }
                } else {
                    presenceViewModel.setOffline()
                }
            })
            .ignoresSafeArea(.all, edges: .bottom)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}
