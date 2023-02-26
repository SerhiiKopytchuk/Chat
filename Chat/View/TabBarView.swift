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
    @EnvironmentObject private var channelViewModel: ChannelViewModel
    @EnvironmentObject private var channelMessagingViewModel: ChannelMessagingViewModel

    @Binding var isShowingSideBar: Bool
    @State private var isShowingEmptyChatsList = false
    @State private var isShowingEmptyChannelsList = false

    @State private var goToChat = false
    @State private var goToChannel = false

    // MARK: tab properties
    @State private var tabs: [Tab] = [
        Tab(name: "Chats", index: 0),
        Tab(name: "Channels", index: 1)
    ]
    @State private var currentTab: Tab = Tab(name: "Chats", index: 0)
    @State private var contentOffset: CGFloat = 0
    @State private var indicatorWidth: CGFloat = 0
    @State private var indicatorPosition: CGFloat = 0

    @State private var headerHeight: CGFloat = 0

    // MARK: - computed vars
    private var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentTab) {
                // MARK: chats tab
                GeometryReader { proxy in
                    let size = proxy.size
                    chatsScrollView
                        .frame(width: size.width, height: size.height)
                }
                .offsetX { rect in
                    if !isShowingSideBar && !goToChat && !goToChannel {
                        if currentTab.name == tabs[0].name && !isShowingSideBar {
                            contentOffset = rect.minX - (rect.width * 0)
                        }
                        updateTabFrame(rect.width)
                    }
                }
                .tag(0)

                // MARK: channels tab
                GeometryReader { proxy in
                    let size = proxy.size
                    channelsScrollView
                        .frame(width: size.width, height: size.height)
                }
                .offsetX { rect in
                    if !isShowingSideBar && !goToChat && !goToChannel {
                        if currentTab.name == tabs[1].name {
                            contentOffset = rect.minX - (rect.width * 1)
                        }
                        updateTabFrame(rect.width)
                    }
                }
                .tag(1)

            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .never))

            dynamicTabHeader()
                .readSize { size in
                    headerHeight = size.height
                }

        }
        .onReceive(chattingViewModel.$chats
            .dropFirst(2)
            .map { $0.count }, perform: { chatsCount in
                if chatsCount == 0 {
                    isShowingEmptyChatsList = true
                } else {
                    isShowingEmptyChatsList = false
                }
            })
        .onReceive(channelViewModel.$channels
            .dropFirst(2)
            .map { $0.count }, perform: { channelsCount in
                if channelsCount == 0 {
                    isShowingEmptyChannelsList = true
                } else {
                    isShowingEmptyChannelsList = false
                }
            })
        .navigationDestination(isPresented: $goToChat, destination: {
            ConversationView(secondUser: viewModel.secondUser, isFindChat: .constant(true))
        })
        .navigationDestination(isPresented: $goToChannel, destination: {
            ChannelConversationView(currentUser: viewModel.currentUser, isSubscribed: .constant(true))
        })
    }

    // MARK: - View Builders

    @ViewBuilder
    func dynamicTabHeader() -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                menuButton

                Text("Chat")
                    .font(.title3.bold())
                    .foregroundColor(Color.secondPrimaryReversed)
            }
            .padding(.leading, 15)

            HStack(spacing: 0) {
                ForEach($tabs) { $tab in
                    Spacer()
                    Text(tab.name)
                        .tracking(2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.secondPrimaryReversed)
                        .offsetX { rect in
                            tab.minX = rect.minX
                            tab.width = rect.width
                        }

                    if tab == tabs.last {
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.top, 15)
            .overlay(alignment: .bottomLeading, content: {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .foregroundColor(Color.secondPrimaryReversed)
                    .frame(width: indicatorWidth, height: 4)
                    .offset(x: indicatorPosition, y: 10)
            })
            .padding(.bottom, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .backgroundBlur(radius: 3, opaque: true)
    }

    @ViewBuilder private var menuButton: some View {
        Button {
            withAnimation(.easeOut) {
                isShowingSideBar.toggle()
            }
        } label: {
            Image(systemName: "list.bullet")
                .font(.title3)
                .scaledToFit()
                .frame(height: 33)
                .foregroundColor(Color.secondPrimaryReversed)
                .padding([.leading, .trailing], 5)
        }
        .padding([.leading, .trailing], 5)
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
                                goToChat.toggle()
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
            chatsEmptyView
        }

    }

    @ViewBuilder private var chatsEmptyView: some View {
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
        .opacity(isShowingEmptyChatsList ? 1 : 0)
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
            chatsEmptyView
        }
    }

    @ViewBuilder private var channelsEmptyView: some View {
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
        .opacity(isShowingEmptyChannelsList ? 1 : 0)
    }

    // MARK: - functions

    func updateTabFrame(_ tabViewWidth: CGFloat ) {
        let inputRange = tabs.indices.compactMap { index -> CGFloat? in
            return CGFloat(index) * tabViewWidth
        }

        let outputRangeForWidth = tabs.compactMap { tab -> CGFloat? in
            return tab.width
        }

        let outputRangeForPosition = tabs.compactMap { tab -> CGFloat? in
            return tab.minX
        }

        let widthInterpolation = LinearInterpolation(inputRange: inputRange, outputRange: outputRangeForWidth)
        let positionInterpolation = LinearInterpolation(inputRange: inputRange, outputRange: outputRangeForPosition)

        indicatorWidth = widthInterpolation.calculate(for: -contentOffset)
        indicatorPosition = positionInterpolation.calculate(for: -contentOffset)

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
    }
}
