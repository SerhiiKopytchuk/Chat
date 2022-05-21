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

    
    var body: some View {
        ZStack{
            Color(.white)
            VStack{
                List{
                    ForEach(chatListsViewModel.chats, id: \.id){ chat in
                        ConversationListRow(name: chat.name, textMessage: chat.lastMessage, time: chat.time) {
                            print("tapped")
                        }
                        
                    }
                }
            }
        }
    }
}
