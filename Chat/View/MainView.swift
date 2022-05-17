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
    

    
        
    var body: some View {
        NavigationView{
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
                    ConversationListRow(name: "Serhii", textMessage: "hello", time: "12:45") {
//                        NavigationLink(destination: EmptyView())
                        print("clicked row")
                    }
//                    ConversationListRow(name: "serhii", textMessage: "hello", time: "12:45")
//                    ConversationListRow(name: "serhii", textMessage: "hello", time: "12:45")
//                    ForEach(conversations, id: \.self) { conversation
//                    ConversationListRow(name: conversation.name, textMessage: conversation.textMessage, time: <#T##String#>)
//                    }
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

