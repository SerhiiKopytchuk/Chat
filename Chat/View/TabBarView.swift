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
    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var messagingViewModel: MessagingViewModel
    @EnvironmentObject private var chattingViewModel: ChattingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject private var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject private var editChannelViewModel: EditChannelViewModel

    @Binding var isShowingSideMenu: Bool

    @State private var currentTab: Tab = .chats
    @State private var goToConversation = false
    @State private var goToChannel = false
    @State private var selection = 0

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: menuButton
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
                    .contentShape(Rectangle())
                    .gesture(DragGesture()
                        .onEnded({ value in
                            if value.translation.width < 30 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selection = 1
                                }
                            }

                            if value.translation.width > 30 {
                                if selection == 0 {
                                    withAnimation(.spring()) {
                                        isShowingSideMenu.toggle()
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selection = 0
                                    }
                                }
                            }
                        })
                    )
                    .safeAreaInset(edge: .top) {
                        EmptyView()
                            .frame(height: 65)
                    }

                // MARK: CustomTabBar
                CustomTabBar(selected: $selection)
                    .padding(.bottom)
                    .backgroundBlur(radius: 20, opaque: true)
                    .clipShape(RoundedRectangle(cornerRadius: 0))
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(.all, edges: .bottom)

        }
        .navigationDestination(isPresented: $goToConversation, destination: {
            ConversationView(secondUser: viewModel.secondUser, isFindChat: .constant(true))
        })
        .navigationDestination(isPresented: $goToChannel, destination: {
            ChannelConversationView(currentUser: viewModel.currentUser, isSubscribed: .constant(true))
        })
        .frame(maxHeight: .infinity)
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }

    // MARK: - View Builders

    @ViewBuilder private var menuButton: some View {
        Button {
            withAnimation(.spring()) {
                isShowingSideMenu.toggle()
            }
        } label: {
            Image(systemName: "list.bullet")
                .foregroundColor(.primary)
        }
        .font(.title3)
        .opacity(isShowingSideMenu ? 0 : 1)
    }

    @ViewBuilder private var chatsScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(chattingViewModel.chats, id: \.id) { chat in
                ChatListRow(chat: chat) {
                    _ = viewModel.getUser(
                        id: viewModel.currentUser.id != chat.user1Id ? chat.user1Id : chat.user2Id
                    ) { user in
                        messagingViewModel.secondUser = user
                        chattingViewModel.secondUser = user

                        DispatchQueue.main.async {
                            goToConversation.toggle()
                        }
                    } failure: { }

                    chattingViewModel.currentChat = chat
                    messagingViewModel.currentUser = self.viewModel.currentUser
                    messagingViewModel.currentChat = chat
                    messagingViewModel.getMessages { _ in }
                }
                .environmentObject(messagingViewModel)
                .environmentObject(chattingViewModel)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder private var channelsScrollView: some View {
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
                .environmentObject(channelMessagingViewModel)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder private var chatsAndChannelsView: some View {
        VStack {
            if selection == 0 {
                chatsScrollView
                    .transition(.push(from: .leading))
            } else {
                channelsScrollView
                    .transition(.push(from: .trailing))
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
