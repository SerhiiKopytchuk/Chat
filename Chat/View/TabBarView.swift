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

    @Binding var isShowingSideBar: Bool
    @State private var isShowingEmptyListsMessage = false

    @State private var goToConversation = false
    @State private var goToChannel = false

    let tabs: [Tab] = [
        Tab(name: "Chats", index: 0),
        Tab(name: "Channels", index: 1)
    ]

    @State var offset: CGFloat = 0
    @State var currentTabIndex: Int = 0
    @State var isTapped = false
    @State private var headerHeight: CGFloat = 0

    // MARK: - computed vars
    private var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentTabIndex) {

                chatsScrollView

                    .tag(0)

                channelsScrollView

                    .tag(1)
            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .never))

            dynamicTabHeader()
                .readSize { size in
                    headerHeight = size.height
                }

        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isShowingEmptyListsMessage = true
            }
        }
        .navigationDestination(isPresented: $goToConversation, destination: {
            ConversationView(secondUser: viewModel.secondUser, isFindChat: .constant(true))
        })
        .navigationDestination(isPresented: $goToChannel, destination: {
            ChannelConversationView(currentUser: viewModel.currentUser, isSubscribed: .constant(true))
        })
    }

    // MARK: - View Builders

    @ViewBuilder
    func dynamicTabHeader() -> some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .center) {

                menuButton
                    .padding(.trailing, 5)

                Text("Chat")
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }

            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab.name)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            isTapped = true
                            withAnimation(.easeInOut) {
                                currentTabIndex = tab.index
                                offset = -(screenSize.width) * CGFloat(tab.index)
                            }
                        }
                }
            }
            .background(alignment: .bottomLeading) {
                Capsule()
                    .fill(.white)
                    .frame(width: (screenSize.width - 90)/CGFloat(tabs.count), height: 4)
                    .offset(y: 12)
                    .offset(x: tabOffset(padding: 30) + 15)
            }
            .padding(.bottom, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder private var menuButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isShowingSideBar.toggle()
            }
        } label: {
            Image(systemName: "list.bullet")
                .font(.title3)
                .foregroundColor(.white)
        }
        .opacity(isShowingSideBar ? 0 : 1)
    }

    @ViewBuilder private var chatsScrollView: some View {
        if !chattingViewModel.chats.isEmpty {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(chattingViewModel.chats, id: \.id) { chat in
                    ChatListRow(chat: chat) {
                        viewModel.getUser(
                            id: viewModel.currentUser.id != chat.user1Id ? chat.user1Id : chat.user2Id
                        ) { user in
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
                    .padding(.horizontal)
                }
            }
            .safeAreaInset(edge: .top) {
                EmptyView()
                    .frame(height: headerHeight  + 5)
            }
        } else {
            VStack(alignment: .center, spacing: 30) {
                Image("noChats")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150, alignment: .center)
                    .addLightShadow()

                Text("No conversations")
                    .font(.title)
                    .fontWeight(.light)

                Text("No messages in your inbox, yet! Start chatting with people around you")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)

            }
            .frame(maxWidth: .infinity)
            .opacity(isShowingEmptyListsMessage ? 1 : 0)
        }

    }

    @ViewBuilder private var channelsScrollView: some View {
        if !channelViewModel.channels.isEmpty {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(channelViewModel.channels, id: \.id) { channel in
                    ChannelListRow(channel: channel) {
                        channelViewModel.getChannel(name: channel.name,
                                                    ownerId: channel.ownerId) { channel, errorDescription in

                            guard let channel, errorDescription == nil else { return }

                            channelMessagingViewModel.currentChannel = channel
                            channelMessagingViewModel.currentUser = viewModel.currentUser
                            channelMessagingViewModel.getMessages(competition: { _ in })
                            self.goToChannel.toggle()
                        }

                    }
                    .padding(.horizontal)
                }
            }
            .safeAreaInset(edge: .top) {
                EmptyView()
                    .frame(height: headerHeight  + 5)
            }
        } else {
            VStack(alignment: .center, spacing: 30) {
                Image("noChannels")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150, alignment: .center)
                    .addLightShadow()

                Text("No channels")
                    .font(.title)
                    .fontWeight(.light)

                Text("Take the initiative to explore new channels or start your own " +
                     "with a compelling heading and call to action.")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .opacity(isShowingEmptyListsMessage ? 1 : 0)
        }
    }

    // MARK: - functions

    func tabOffset(padding: CGFloat) -> CGFloat {
        return (-offset / screenSize.width) * ((screenSize.width - padding) / CGFloat(2))
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(UserViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChattingViewModel())
            .environmentObject(ChannelViewModel())
            .environmentObject(ChannelMessagingViewModel())
            .environmentObject(EditChannelViewModel())
//        TabBarView(isShowingSideBar: .constant(false))
//            .environmentObject(UserViewModel())
//            .environmentObject(MessagingViewModel())
//            .environmentObject(ChattingViewModel())
//            .environmentObject(ChannelViewModel())
//            .environmentObject(ChannelMessagingViewModel())
//            .environmentObject(EditChannelViewModel())
    }
}
