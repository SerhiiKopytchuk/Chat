//
//  TabBarView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 21.05.2022.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct TabBarView: View {

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel

    @State var currentTab: Tab = .chats
    @State var goToConversation = false
    @State var goToChannel = false

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
                    ConversationView(secondUser: viewModel.secondUser, isFindChat: .constant(true))
                        .environmentObject(viewModel)
                        .environmentObject(messagingViewModel)
                } label: { }
                    .hidden()

                NavigationLink(isActive: $goToChannel) {
                    ChannelConversationView(currentUser: viewModel.currentUser, isSubscribed: .constant(true))
                        .environmentObject(viewModel)
                        .environmentObject(channelMessagingViewModel)
                        .environmentObject(channelViewModel)
                } label: { }
                    .hidden()
            }
        }
    }

    @ViewBuilder var chatsView: some View {
        VStack(alignment: .leading) {
            Text("Chats")
                .font(.title)
                .bold()
                .padding(.horizontal)
                .padding(.top)
            List {
                ForEach(chattingViewModel.chats, id: \.id) { chat in

                    ChatListRow(chat: chat) {
                        _ = viewModel.getUser(
                            id: viewModel.currentUser.id != chat.user1Id ? chat.user1Id : chat.user2Id
                        ) { user in
                            messagingViewModel.secondUser = user
                        } failure: { }

                        chattingViewModel.getCurrentChat(
                            chat: chat, userNumber: viewModel.currentUser.id != chat.user1Id ? 1 : 2
                        ) { chat in
                            messagingViewModel.user = self.viewModel.currentUser
                            messagingViewModel.currentChat = chat
                            messagingViewModel.getMessages { _ in }
                            // don't remove dispatch
                            DispatchQueue.main.async {
                                goToConversation.toggle()
                            }
                        }
                    }
                    .environmentObject(messagingViewModel)
                    .environmentObject(chattingViewModel)
                }
            }
        }
    }

    @ViewBuilder var channelsView: some View {
        VStack(alignment: .leading) {
            Text("Channels")
                .font(.title)
                .bold()
                .padding(.horizontal)
                .padding(.top)
            List {
                ForEach(channelViewModel.channels, id: \.id) { channel in
                    ChannelListRow(channel: channel) {
                        channelViewModel.getCurrentChannel(name: channel.name, ownerId: channel.ownerId) { channel in
                            channelMessagingViewModel.currentChannel = channel
                            channelMessagingViewModel.currentUser = viewModel.currentUser
                            channelMessagingViewModel.getMessages(competition: { _ in })
                            DispatchQueue.main.async {
                                self.goToChannel.toggle()
                            }
                        } failure: { _ in }

                    }
                    .environmentObject(viewModel)
                    .environmentObject(channelViewModel)
                }
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(UserViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChattingViewModel())
    }
}

extension View {
}
