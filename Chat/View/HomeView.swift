//
//  HomeView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 21.05.2022.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct HomeView: View {

    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    @State var currentTab: Tab = .chats
    @State var goToConversation = false
    @State var goToCreateChannel = false

    init() {
        UITabBar.appearance().isHidden = true
        UITableView.appearance().backgroundColor = .white
        // can we make bg of list like this?
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $currentTab) {

                    chatsView
                    .tag(Tab.chats)

                    channelsView
                        .tag(Tab.channels)
                }
                CustomTabBar(currentTab: $currentTab)
                    .background(.white)
                NavigationLink(isActive: $goToConversation) {
                    ConversationView(user: viewModel.secondUser, isFindChat: .constant(true))
                        .environmentObject(viewModel)
                        .environmentObject(messagingViewModel)
                } label: { }
                    .hidden()

                NavigationLink(isActive: $goToCreateChannel) {
                    CreateChannelView()
                        .environmentObject(viewModel)
                        .environmentObject(ChannelViewModel())
                } label: { }
                    .hidden()
            }
        }
    }

    @ViewBuilder var chatsView: some View {
        VStack {
            List {
                ForEach(chattingViewModel.chats, id: \.id) { chat in

                    ConversationListRow(chat: chat) {
                        _ = viewModel.getUser(
                            id: viewModel.user.id != chat.user1Id ? chat.user1Id : chat.user2Id
                        ) { user in
                            messagingViewModel.secondUser = user
                        } failure: { }

                        chattingViewModel.getCurrentChat(
                            chat: chat, userNumber: viewModel.user.id != chat.user1Id ? 1 : 2
                        ) { chat in
                            messagingViewModel.user = self.viewModel.user
                            messagingViewModel.currentChat = chat
                            messagingViewModel.getMessages { _ in
                            }
                            DispatchQueue.main.async {
                                goToConversation.toggle()
                            }
                        }
                    }
                    .environmentObject(messagingViewModel)
                }
            }

        }
    }

    @ViewBuilder var channelsView: some View {
        VStack {
            HStack {
                Spacer()
                createButton
            }
            .padding()
            List {
                ForEach(chattingViewModel.chats, id: \.id) { chat in

                    ConversationListRow(chat: chat) {
                        _ = viewModel.getUser(
                            id: viewModel.user.id != chat.user1Id ? chat.user1Id : chat.user2Id
                        ) { user in
                            messagingViewModel.secondUser = user
                        } failure: { }

                        chattingViewModel.getCurrentChat(
                            chat: chat, userNumber: viewModel.user.id != chat.user1Id ? 1 : 2
                        ) { chat in
                            messagingViewModel.user = self.viewModel.user
                            messagingViewModel.currentChat = chat
                            messagingViewModel.getMessages { _ in
                            }
                            DispatchQueue.main.async {
                                goToConversation.toggle()
                            }
                        }
                    }
                    .environmentObject(messagingViewModel)
                }
            }

        }
    }

    @ViewBuilder var createButton: some View {
        Button {
            goToCreateChannel.toggle()
        } label: {
            HStack {
                Text("create channel")
                Image(systemName: "plus")
            }
        }
        .padding(10)
        .background(.orange)
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChattingViewModel())
    }
}

extension View {
}
