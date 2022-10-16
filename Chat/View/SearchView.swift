//
//  SearchUsersView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 03.06.2022.
//

import SwiftUI
struct SearchView: View {

    // MARK: - vars
    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var messagingViewModel: MessagingViewModel
    @EnvironmentObject private var chattingViewModel: ChattingViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel
    @EnvironmentObject private var channelMessagingViewModel: ChannelMessagingViewModel

    @Namespace var animation

    @Environment(\.self) var env

    @State private var showSearchBar = false
    @State private var searchUserText = ""
    @State private var searchChannelText = ""

    @State private var goToConversation = false
    @State private var isFindChat = true

    @State private var goToChannelConversation = false
    @State private var isSubscribedToChannel = true

    @State private var isSearchingChat = "Users"

    // MARK: - body
    var body: some View {
        VStack {

            HeaderWithBackButton(environment: _env, text: "Search") {
                withAnimation {
                    self.clearData()
                }
            }
                .padding()

            VStack {
                chatOrChannelPicker

                if isSearchingChat == "Users" {
                    searchingUsers
                } else {
                    searchingChannels
                }

            }
            .padding()

        }
        .addRightGestureRecognizer {
            env.dismiss()
        }
        .background {
            Color("BG")
                .ignoresSafeArea()
        }
        .navigationDestination(isPresented: $goToConversation, destination: {
            ConversationView(secondUser: self.viewModel.secondUser, isFindChat: self.$isFindChat)
        })
        .navigationDestination(isPresented: $goToChannelConversation, destination: {
            ChannelConversationView(currentUser: viewModel.currentUser, isSubscribed: $isSubscribedToChannel)
        })
        .navigationBarHidden(true)

    }

    // MARK: - viewBuilders

    @ViewBuilder private var searchingUsers: some View {
        Label {
            TextField("Enter user name", text: $searchUserText)
                .foregroundColor(.primary)
                .padding(.leading, 10)
                .onChange(of: searchUserText, perform: { newValue in
                    viewModel.searchText = newValue
                    viewModel.getAllUsers()
                })
        } icon: {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.primary)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.secondPrimary)
        }
        .padding(.top, 15)
        .padding(.bottom)

        usersList
    }

    @ViewBuilder private var searchingChannels: some View {
        Label {
            TextField("Enter channel name", text: $searchChannelText)
                .foregroundColor(.primary)
                .padding(.leading, 10)
                .onChange(of: searchChannelText, perform: { newText in
                    channelViewModel.searchText = newText
                    channelViewModel.getSearchChannels()
                })
        } icon: {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.primary)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.secondPrimary)
        }
        .padding(.top, 15)
        .padding(.bottom)

        channelList
    }

    @ViewBuilder private var chatOrChannelPicker: some View {
        HStack(spacing: 0) {
            ForEach(["Users", "Channels"], id: (\.self)) { text in
                Text(text.capitalized)
                    .fontWeight(.semibold)
                    .foregroundColor(isSearchingChat == text ? .white : .primary)
                    .opacity(isSearchingChat == text ? 1 : 0.7)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background {
                        if isSearchingChat == text {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    Color.mainGradient
                                )
                                .matchedGeometryEffect(id: "TYPE", in: animation)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.isSearchingChat = text
                        }
                    }
            }
        }
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.secondPrimary)
        }
    }

    @ViewBuilder private var usersList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(viewModel.users, id: \.id) { user in
                SearchUserListRow(userName: user.name,
                                  userGmail: user.gmail,
                                  id: user.id,
                                  userColor: user.colour,
                                  rowTapped: {

                    viewModel.secondUser = user
                    messagingViewModel.secondUser = user
                    messagingViewModel.currentUser = viewModel.currentUser
                    chattingViewModel.secondUser = user
                    chattingViewModel.currentUser = viewModel.currentUser

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
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private var channelList: some View {
        ScrollView(.vertical, showsIndicators: false) {
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

    // MARK: - functions

    private func clearData() {
        self.searchUserText = ""
        viewModel.searchText = ""
        viewModel.getAllUsers()

        self.searchChannelText = ""
        channelViewModel.searchText = ""
        channelViewModel.getSearchChannels()
    }

}
