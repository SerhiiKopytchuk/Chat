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
            .padding(.horizontal)

        }
        .addRightGestureRecognizer {
            env.dismiss()
        }
        .background {
            Color.background
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
        TextFieldWithBorders(iconName: "magnifyingglass",
                             placeholderText: "Enter user name",
                             text: $searchUserText,
                             color: Color.secondPrimaryReversed)
        .onChange(of: searchUserText, perform: { newValue in
            viewModel.searchText = newValue
            viewModel.getAllUsers()
        })
        .padding(.top, 15)
        .padding(.bottom)

        usersList
    }

    @ViewBuilder private var searchingChannels: some View {

        TextFieldWithBorders(iconName: "magnifyingglass",
                             placeholderText: "Enter channel name",
                             text: $searchChannelText,
                             color: Color.secondPrimaryReversed)
        .onChange(of: searchChannelText, perform: { newText in
            channelViewModel.searchText = newText
            channelViewModel.getSearchChannels()
        })
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
            LazyVStack {
                ForEach(viewModel.users, id: \.id) { user in
                    SearchUserListRow(userName: user.name,
                                      userGmail: user.gmail,
                                      id: user.id,
                                      userColor: user.colour,
                                      rowTapped: {

                        viewModel.secondUser = user
                        messagingViewModel.currentUser = viewModel.currentUser
                        chattingViewModel.secondUser = user
                        chattingViewModel.currentUser = viewModel.currentUser

                        chattingViewModel.getCurrentChat(with: user) { result in
                            switch result {
                            case .success(let chat):
                                self.messagingViewModel.currentChat = chat
                                self.messagingViewModel.getMessages { _ in
                                    isFindChat = true
                                    goToConversation = true
                                }
                            case .failure:
                                isFindChat = false
                                goToConversation = true
                            }
                        }
                    })
                }
            }
        }
        .ignoresSafeArea()
        .scrollDismissesKeyboard(.immediately)
    }

    @ViewBuilder private var channelList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(channelViewModel.searchChannels, id: \.id) { channel in
                    ChannelListRow(channel: channel) {

                        channelMessagingViewModel.currentUser = viewModel.currentUser
                        channelMessagingViewModel.currentChannel = channel
                        channelViewModel.currentUser = viewModel.currentUser
                        channelViewModel.currentChannel = channel
                        self.isSubscribedToChannel = channelViewModel.doesUsesSubscribed
                        channelMessagingViewModel.getMessages { _ in
                            DispatchQueue.main.async {
                                self.goToChannelConversation = true
                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .scrollDismissesKeyboard(.immediately)
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(UserViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChattingViewModel())
            .environmentObject(ChannelViewModel())
            .environmentObject(ChannelMessagingViewModel())
    }
}
