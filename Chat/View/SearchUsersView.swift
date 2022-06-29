//
//  SearchUsersView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 03.06.2022.
//

import SwiftUI

struct SearchUsersView: View {

    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    @State var showSearchBar = false
    @State var searchText = ""
    @State var goToConversation = false
    @State var isFindChat = true

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Search users", text: $searchText).onChange(of: searchText, perform: { newValue in
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

        }
        .background {
            NavigationLink(isActive: $goToConversation) {
                ConversationView(secondUser: self.viewModel.secondUser, isFindChat: self.$isFindChat)
                    .environmentObject(viewModel)
                    .environmentObject(messagingViewModel)
                    .environmentObject(chattingViewModel)
            }label: { Text("conversationView") }
        }
    }

    @ViewBuilder var usersList: some View {
            List {
                ForEach(viewModel.users, id: \.id) { user in
                    SearchUserCell(user: user.name,
                                   userGmail: user.gmail,
                                   id: user.id,
                                   rowTapped: {
                        viewModel.secondUser = user
                        messagingViewModel.secondUser = user
                        messagingViewModel.user = viewModel.user
                        chattingViewModel.secondUser = user
                        chattingViewModel.user = viewModel.user

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
}

struct SearchUsersView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUsersView()
            .environmentObject(AppViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChattingViewModel())
    }
}
