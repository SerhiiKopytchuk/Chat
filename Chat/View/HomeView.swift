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
    
    init(){
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                TabView(selection: $currentTab){
                    
                    VStack{
                        List{
                            ForEach(chatListsViewModel.chats, id: \.id){ chat in
                                ConversationListRow(name: chat.name, textMessage: chat.lastMessage, time: chat.time) {
                                    print("tapped")
                                }
                                
                            }
                        }
                    }.tag(Tab.chats)
                    
                    Text("Chanels")
                        .tag(Tab.chanels)
                }
                CustomTabBar(currentTab: $currentTab)
                    .background(.white)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

extension View{
}
