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

    @Binding var isShowingSideMenu: Bool

    @State private var goToConversation = false
    @State private var goToChannel = false

    let tabs: [Tab] = [
        Tab(name: "Chat", index: 0),
        Tab(name: "Channel", index: 1)
    ]

    @State var offset: CGFloat = 0
    @State var currentTabIndex: Int = 0
    @State var isTapped = false
    @StateObject var gestureManager: InteractionManager = .init()

    // MARK: - computed vars
    private var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentTabIndex) {
                chatsScrollView
                    .ignoresSafeArea()
                    .offsetX { value in
                        if currentTabIndex == 0 && !isTapped {
                            offset = value - (screenSize.width * CGFloat(0))
                        }

                        if value == 0 && isTapped {
                            isTapped = false
                        }

                        if isTapped && gestureManager.isInteracting {
                            isTapped = false
                        }
                    }
                    .tag(0)

                channelsScrollView
                    .ignoresSafeArea()
                    .offsetX { value in
                        if currentTabIndex == 1 && !isTapped {
                            offset = value - (screenSize.width * CGFloat(1))
                        }

                        if value == 0 && isTapped {
                            isTapped = false
                        }

                        if isTapped && gestureManager.isInteracting {
                            isTapped = false
                        }
                    }
                    .tag(1)
            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear(perform: gestureManager.addGesture)
            .onDisappear(perform: gestureManager.removeGesture)
            dynamicTabHeader()
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
            Text("Dynamic tabs")
                .font(.title.bold())
                .foregroundColor(.white)
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
                    .frame(width: (screenSize.width - 30)/CGFloat(tabs.count), height: 4)
                    .offset(y: 12)
                    .offset(x: tabOffset(padding: 30))
            }
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
    }

    @ViewBuilder private var channelsScrollView: some View {
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
    }

    // MARK: - functions

    func tabOffset(padding: CGFloat) -> CGFloat {
        return (-offset / screenSize.width) * ((screenSize.width - padding) / CGFloat(2))
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
