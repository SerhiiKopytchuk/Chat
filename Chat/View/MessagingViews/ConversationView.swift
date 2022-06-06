//
//  ConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI

struct ConversationView: View {
    @State var user:User
    
    @EnvironmentObject var viewModel:AppViewModel
    
    var body: some View {
        VStack {
            VStack{
                TitleRow(user: user)
                ScrollViewReader{ proxy in
                    ScrollView{
                        ForEach(viewModel.currentChat.messages ?? [Message(id: "", text: "Ups, something went wrong(", senderId: "", timestamp: Date())], id: \.id){ message in
                            MessageBubble(message: message)
                        }
                    }
                    
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
//                    .onChange(of: messagesManager.lastMessageId) { id in
//                        withAnimation {
//                            proxy.scrollTo(id, anchor: .bottom)
//                        }
//                    }
                }
            }
            .background(Color("Peach"))
            MessageField()
                .environmentObject(viewModel)
        }
        
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(user: User(chats: [], gmail: "", id: "", name: ""))
    }
}
