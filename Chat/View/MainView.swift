//
//  MainView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 16.05.2022.
//

import SwiftUI
import Firebase

struct MainView: View {
    
//    @EnvironmentObject var viewModel: AppViewModel
    @ObservedObject var viewModel: AppViewModel = AppViewModel()
    @ObservedObject var chatListsViewModel = ChatListViewModel()

    
        
    var body: some View {
            VStack{
                HStack{
                    Button {
                        try! Auth.auth().signOut()
                        viewModel.signedIn = false
                        
                    } label: {
                        Text("Sign Out")
                            .padding(10)
                            .foregroundColor(.white)
                            .background(.brown)
                            .cornerRadius(20)
                            .padding()
                    }
                    Spacer()
                    Text(viewModel.username)

                }
                
                

                Text("Chats")
                    .font(.system(.largeTitle, design: .rounded))
                    .foregroundColor(.orange)
                    .padding()
                
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

