//
//  ConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI

struct ConversationView: View {
    var messages = ["Hello", "How are you doing?", "I've benn building apllications from scratch"]
    @StateObject var messagesManager:AppViewModel = AppViewModel()
    
    var body: some View {
        VStack {
            VStack{
                TitleRow()
                ScrollViewReader{ proxy in
                    ScrollView{
                        ForEach(messagesManager.messages, id: \.id){ message in
                            MessageBubble(message: message)
                        }
                    }
                    
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .onChange(of: messagesManager.lastMessageId) { id in
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color("Peach"))
            MessageField()
                .environmentObject(messagesManager)
        }
        
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView()
    }
}
