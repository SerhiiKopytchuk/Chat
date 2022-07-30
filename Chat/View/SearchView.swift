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

    @Namespace var animation

    @Environment(\.self) var env

    @State var showSearchBar = false
    @State var searchUserText = ""
    @State var searchChannelText = ""
    @State var goToConversation = false
    @State var isFindChat = true

    @State var goToChannelConversation = false
    @State var isSubscribedToChannel = true

    @State var isSearchingChat = "Users"

    // MARK: - body
    var body: some View {
        VStack {

            header

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
        .background {
            navigationLinks
            Color("BG")
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)

    }

    // MARK: - viewBuilders

    @ViewBuilder var header: some View {
        HStack(spacing: 15) {
            Button {
                env.dismiss()
            } label: {
                Image(systemName: "arrow.backward.circle.fill")
                    .toButtonLightStyle(size: 40)
            }

            Text("Search")
                .font(.title.bold())
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }

    @ViewBuilder var searchingUsers: some View {
        Label {
            TextField("Enter user name", text: $searchUserText)
                .padding(.leading, 10)
                .onChange(of: searchUserText, perform: { newValue in
                    viewModel.searchText = newValue
                    viewModel.getAllUsers()
                })
        } icon: {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white)
        }
        .padding(.top, 15)

        usersList
    }

    @ViewBuilder var searchingChannels: some View {
        Label {
            TextField("Enter channel name", text: $searchChannelText)
                .padding(.leading, 10)
                .onChange(of: searchChannelText, perform: { newText in
                    channelViewModel.searchText = newText
                    channelViewModel.getSearchChannels()
                })
        } icon: {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white)
        }
        .padding(.top, 15)

        channelList
    }

    @ViewBuilder var chatOrChannelPicker: some View {
        HStack(spacing: 0) {
            ForEach(["Users", "Channels"], id: (\.self)) { text in
                Text(text.capitalized)
                    .fontWeight(.semibold)
                    .foregroundColor(isSearchingChat == text ? .white : .black)
                    .opacity(isSearchingChat == text ? 1 : 0.7)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background {
                        if isSearchingChat == text {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    LinearGradient(colors: [
                                        Color("Gradient1"),
                                        Color("Gradient2"),
                                        Color("Gradient3")
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
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
                .fill(.white)
        }
    }

    @ViewBuilder var usersList: some View {
        ScrollView(.vertical, showsIndicators: false) {
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
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder var channelList: some View {
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

    @ViewBuilder var navigationLinks: some View {
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
