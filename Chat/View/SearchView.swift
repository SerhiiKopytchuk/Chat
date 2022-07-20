//
//  SearchUsersView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 03.06.2022.
//

import SwiftUI

struct SearchView: View {

    // MARK: - vars
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel

    @State var showSearchBar = false
    @State var searchUserText = ""
    @State var searchChannelText = ""
    @State var goToConversation = false
    @State var isFindChat = true

    @State var goToChannelConversation = false
    @State var isSubscribedToChannel = true

    @State var isSearchingChat = true

    // MARK: - body
    var body: some View {
        VStack {
            Picker("search users or channels", selection: $isSearchingChat) {
                Text("Users").tag(true)
                Text("Channels").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()

            if isSearchingChat {
                HStack {
                    TextField("Search users", text: $searchUserText).onChange(of: searchUserText, perform: { newValue in
                        viewModel.searchText = newValue
                        viewModel.getAllUsers()
                    })
                    .textFieldStyle(.roundedBorder)

                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(width: 50, height: 50)

                }
                .padding()
                usersList
            } else {
                HStack {
                    TextField("Search channels", text: $searchChannelText)
                        .onChange(of: searchChannelText, perform: { newText in
                        channelViewModel.searchText = newText
                        channelViewModel.getAllChannels()
                    })
                    .textFieldStyle(.roundedBorder)

                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(width: 50, height: 50)

                }
                .padding()
                channelList
            }

        }
        .background {
            NavigationLink(isActive: $goToConversation) {
                ConversationView(secondUser: self.viewModel.secondUser, isFindChat: self.$isFindChat)
                    .environmentObject(viewModel)
                    .environmentObject(messagingViewModel)
                    .environmentObject(chattingViewModel)
            }label: { Text("conversationView") }
                .hidden()

            NavigationLink(isActive: $goToChannelConversation) {
                ChannelConversationView(currentUser: viewModel.currentUser, isSubscribed: $isSubscribedToChannel)
                    .environmentObject(viewModel)
                    .environmentObject(channelViewModel)
                    .environmentObject(channelMessagingViewModel)
            } label: { Text("channelConversationView") }
                .hidden()

        }
    }

    // MARK: - viewBuilders
    @ViewBuilder var usersList: some View {
            List {
                ForEach(viewModel.users, id: \.id) { user in
                    SearchUserCell(user: user.name,
                                   userGmail: user.gmail,
                                   id: user.id,
                                   rowTapped: {
                        viewModel.secondUser = user
                        messagingViewModel.secondUser = user
                        messagingViewModel.user = viewModel.currentUser
                        chattingViewModel.secondUser = user
                        chattingViewModel.user = viewModel.currentUser

                        chattingViewModel.getCurrentChat(secondUser: user) { chat in
                            self.messagingViewModel.currentChat = chat
                            self.messagingViewModel.getMessages { _ in
                                isFindChat = true
                                DispatchQueue.main.async {
                                    goToConversation = true
                                }
                            }
                        } failure: { _ in
                            isFindChat = false
                            goToConversation = true
                        }
                    })
                }
            }
    }

    @ViewBuilder var channelList: some View {
            List {
                ForEach(channelViewModel.searchChannels, id: \.id) { channel in
                    ChannelListRow(channel: channel) {

                        channelMessagingViewModel.currentUser = viewModel.currentUser
                        channelMessagingViewModel.currentChannel = channel
                        channelViewModel.currentUser = viewModel.currentUser
                        channelViewModel.currentChannel = channel
                        self.isSubscribedToChannel = channelViewModel.doesUsesSubscribed()
                        channelMessagingViewModel.getMessages { _ in
                            DispatchQueue.main.async {
                                self.goToChannelConversation = true
                            }
                        }
                    }
                    .environmentObject(viewModel)
                    .environmentObject(channelViewModel)
                }
            }
    }
}
