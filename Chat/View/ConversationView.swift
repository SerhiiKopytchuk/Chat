//
//  ConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI

struct ConversationView: View {
    var messages = ["Hello", "How are you doing?", "I've benn building apllications from scratch"]
    
    var body: some View {
        VStack {
            VStack{
                TitleRow()
                ScrollView{
                    ForEach(messages, id: \.self){ text in
                        MessageBubble(message: Message(id: "", text: text, recived: true, timestamp: Date()))
                    }
                }
                .padding(.top, 10)
                .background(.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
            .background(Color("Peach"))
            MessageField()
        }
        
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView()
    }
}
