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

    @State var showSearchBar = false
    @State var searchText = ""
    @State var goToConversation = false
    @State var userWithConversation = User(chats: [], gmail: "", id: "", name: "")
    @State var isFindedChat = true

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Search users", text: $searchText).onChange(of: searchText, perform: { newValue in
                    viewModel.searchText = newValue
                    viewModel.getAllUsers()
                })
                    .textFieldStyle(DefaultTextFieldStyle())

                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)

            }
            .padding()
            List {
                ForEach(viewModel.users, id: \.id) { user in
                    NavigationLink(isActive: $goToConversation) {
                        ConversationView(user: self.userWithConversation, isFindedChat: self.isFindedChat)
                            .environmentObject(messagingViewModel)
                    }label: {
                        SearchUserCell(user: user.name, userGmail: user.gmail, id: user.id, rowTapped: {
                            self.userWithConversation = user
                            self.viewModel.secondUser = user
                            self.messagingViewModel.secondUser = user

                            viewModel.getCurrentChat(secondUser: user) { chat in
                                self.messagingViewModel.currentChat = chat
                                self.messagingViewModel.getMessages { messages in
                                    self.messagingViewModel.currentChat.messages = messages
                                    isFindedChat = true
                                    goToConversation.toggle()
                                }
                            } failure: { _ in
                                isFindedChat = false
                                goToConversation.toggle()
                            }
                        })
                    }

                }
            }

        }
    }
}

struct SearchUsersView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUsersView()
            .environmentObject(AppViewModel())
    }
}
