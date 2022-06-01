//
//  MessageBubble.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI

struct MessageBubble: View {
    
    var message: Message
    @State private var showTime = false
    
    var body: some View {
        VStack(alignment: message.recived ? .leading : .trailing){
            HStack{
                Text(message.text)
                    .padding()
                    .background(message.recived ? Color("Gray") : Color("Peach"))
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: message.recived ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }
            
            if showTime{
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.recived ? .leading : .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.recived ? .leading : .trailing)
        .padding(message.recived ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(message: Message(id: "1243`", text: "I've been coding chat app, that so interestion", recived: false, timestamp: Date()))
    }
}
