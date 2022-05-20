//
//  MainView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 16.05.2022.
//

import SwiftUI
import Firebase

struct MainView: View {
    

    @State private var isShowingSideMenu = false
    
        
    var body: some View {
        ZStack {
            if isShowingSideMenu{
                SideMenuView(isShowingSideMenu: $isShowingSideMenu)
            }
            HomeView()
                .cornerRadius(isShowingSideMenu ? 20 : 10)
                .offset(x: isShowingSideMenu ? 300 : 0, y: isShowingSideMenu ? 44 : 0)
                .scaleEffect(isShowingSideMenu ? 0.8 : 1)
                .navigationBarItems(leading: Button(action: {
                    withAnimation(.spring()){
                        isShowingSideMenu.toggle()
                    }
                }, label: {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.black)
                }) )
                .shadow(color: .black, radius: isShowingSideMenu ? 30 : 0)
        }
        .onAppear{
            isShowingSideMenu = false
        }
        
            
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


struct HomeView: View {
    
    @ObservedObject var viewModel: AppViewModel = AppViewModel()
    @ObservedObject var chatListsViewModel = ChatListViewModel()

    
    var body: some View {
        ZStack{
            Color(.white)
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
