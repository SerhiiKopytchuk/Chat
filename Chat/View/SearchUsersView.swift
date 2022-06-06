//
//  SearchUsersView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 03.06.2022.
//

import SwiftUI

struct SearchUsersView: View {
    
    @EnvironmentObject var viewModel:AppViewModel
    @State var showSearchBar = false
    @State var searchText = ""
    @State var goToConversation = false
    @State var userWithConversation = User(chats: [], gmail: "", id: "", name: "")
    
    var body: some View {
        VStack{
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
            List{
                ForEach(viewModel.users, id: \.id){ user in
                    searchUserCell(user: user.name, userGmail: user.gmail, rowTapped: {
                        self.userWithConversation = user
                        goToConversation.toggle()
                    })
                }
            }
        }
        NavigationLink(isActive: $goToConversation) {
            ConversationView(user: self.userWithConversation)
        }label: {
            
        }
    }
}

struct SearchUsersView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUsersView()
            .environmentObject(AppViewModel())
    }
}
