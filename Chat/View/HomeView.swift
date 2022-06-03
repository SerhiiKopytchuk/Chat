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
    @ObservedObject var chatListsViewModel = ChatListViewModel()
    @State var currentTab: Tab = .chats
    @State var GoToConversation = false

    
    init(){
        UITabBar.appearance().isHidden = true
        UITableView.appearance().backgroundColor = .white
        //can we make bg of list like this?
    }
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                TabView(selection: $currentTab){
                    
                    VStack{
                        List{
                            ForEach(chatListsViewModel.chats, id: \.id){ chat in
                                ConversationListRow(name: chat.name, textMessage: chat.lastMessage, time: chat.time) {
                                    GoToConversation.toggle()
                                }
                            } 
                        }

                    }.tag(Tab.chats)
                    
                    Text("Chanels")
                        .tag(Tab.chanels)
                }
                CustomTabBar(currentTab: $currentTab)
                    .background(.white)
                NavigationLink(isActive: $GoToConversation) {
                    ConversationView()
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

extension View{
}
