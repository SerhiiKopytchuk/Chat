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
            .padding(.leading, 30)
            List{
                ForEach(viewModel.users, id: \.id){ user in
                   
                        Text(user.name)
                    
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
