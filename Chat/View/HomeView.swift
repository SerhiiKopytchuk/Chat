//
//  HomeView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 21.05.2022.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct HomeView: View {

    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @State var currentTab: Tab = .chats
    @State var goToConversation = false

    init() {
        UITabBar.appearance().isHidden = true
        UITableView.appearance().backgroundColor = .white
        // can we make bg of list like this?
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $currentTab) {

                    VStack {
                        List {
                            ForEach(viewModel.chats, id: \.id) { chat in

                                ConversationListRow(chat: chat) {
                                    _ = viewModel.getUser(
                                        id: viewModel.user.id != chat.user1Id ? chat.user1Id : chat.user2Id
                                    ) { user in
                                        messagingViewModel.secondUser = user
                                    }

                                    viewModel.getCurrentChat(
                                        chat: chat, userNumber: viewModel.user.id != chat.user1Id ? 1 : 2
                                    ) { chat in
                                        messagingViewModel.user = self.viewModel.user
                                        messagingViewModel.currentChat = chat
                                        messagingViewModel.getMessages { _ in
                                        }
                                        DispatchQueue.main.async {
                                            goToConversation.toggle()
                                        }
                                    }
                                }
                                .environmentObject(messagingViewModel)
                            }
                        }

                    }.tag(Tab.chats)

                    Text("Chanels")
                        .tag(Tab.chanels)
                }
                CustomTabBar(currentTab: $currentTab)
                    .background(.white)

                NavigationLink(isActive: $goToConversation) {
                    ConversationView(user: viewModel.secondUser, isFindChat: .constant(true))
                        .environmentObject(viewModel)
                        .environmentObject(messagingViewModel)
                } label: {

                }

            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppViewModel())
    }
}

extension View {
}
