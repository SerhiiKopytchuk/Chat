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

    // MARK: - vars
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var editChannelViewModel: EditChannelViewModel

    @Binding var isShowingSideMenu: Bool

    @State var currentTab: Tab = .chats
    @State var goToConversation = false
    @State var goToChannel = false
    @State var selection = 0

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: menuButton with lists

            menuButton
                .padding(.top)
                .padding(.leading)

            // MARK: chats and channels labels
            VStack(alignment: .leading, spacing: 4) {
                Text( selection == 0 ? "Chats" : "Channels")
                    .font(.title2.bold())
            }
            .padding(.horizontal)
            .padding(.top)

            ZStack(alignment: .top) {
                // MARK: chats and channels lists
                chatsAndChannelsView
                    .safeAreaInset(edge: .top) {
                        EmptyView()
                            .frame(height: 65)
                    }

                // MARK: CustomTabBar
                CustomTabBar(selected: $selection)
                    .padding(.bottom)
                    .backgroundBlur(radius: 10, opaque: true)
                    .clipShape(RoundedRectangle(cornerRadius: 0))
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(.all, edges: .bottom)

        }
        .frame(maxHeight: .infinity)
        .background {

            Color("BG")
                .ignoresSafeArea()

            // MARK: navigationLinks
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
                    .environmentObject(editChannelViewModel)
            } label: { }
                .hidden()
        }
        .navigationBarHidden(true)
    }

    // MARK: - View Builders

    @ViewBuilder var menuButton: some View {
        Button {
            withAnimation(.spring()) {
                isShowingSideMenu.toggle()
            }
        } label: {
            Image(systemName: "list.bullet")
                .foregroundColor(.black)
        }
        .font(.title3)
        .opacity(isShowingSideMenu ? 0 : 1)
    }

    @ViewBuilder var chatsScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
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
                        messagingViewModel.currentUser = self.viewModel.currentUser
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
        .padding(.horizontal)
    }

    @ViewBuilder var channelsScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(channelViewModel.channels, id: \.id) { channel in
                ChannelListRow(channel: channel) {
                    channelViewModel.getCurrentChannel(name: channel.name,
                                                       ownerId: channel.ownerId) { channel in
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
        .padding(.horizontal)
    }

    @ViewBuilder var chatsAndChannelsView: some View {
        VStack {
            if selection == 0 {
                chatsScrollView
                    .transition(.offset(x: -UIScreen.main.bounds.width))
            } else {
                channelsScrollView
                    .transition(.offset(x: UIScreen.main.bounds.width))
            }
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.all, edges: .bottom)
    }

}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(isShowingSideMenu: .constant(false))
            .environmentObject(UserViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChattingViewModel())
            .environmentObject(ChannelViewModel())
            .environmentObject(ChannelMessagingViewModel())
            .environmentObject(EditChannelViewModel())
    }
}

extension View {
}
