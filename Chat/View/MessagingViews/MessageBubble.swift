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
    @EnvironmentObject var viewModel: UserViewModel

    var body: some View {
        VStack(alignment: message.senderId != viewModel.getUserUID() ? .leading : .trailing) {
            HStack {
                Text(message.text)
                    .padding()
                    .foregroundColor(message.senderId != viewModel.getUserUID() ? .white : .black)
                    .background(message.senderId != viewModel.getUserUID() ? .blue : Color.white)
                    .cornerRadius(15, corners: message.senderId != viewModel.getUserUID()
                                  ? [.topLeft, .topRight, .bottomRight] : [.topLeft, .topRight, .bottomLeft])
            }
            .frame(maxWidth: 300, alignment: message.senderId != viewModel.getUserUID() ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }

            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.senderId != viewModel.getUserUID() ? .leading : .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.senderId != viewModel.getUserUID() ? .leading : .trailing)
        .padding(message.senderId != viewModel.getUserUID() ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(message:
                        Message()
        )
            .environmentObject(UserViewModel())
    }
}
