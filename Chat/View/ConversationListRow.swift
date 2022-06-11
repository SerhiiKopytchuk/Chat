//
//  ConversationListRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.05.2022.
//
import Foundation
import SwiftUI

struct ConversationListRow: View {
    // Inject properties into the struct
    @EnvironmentObject var viewModel: AppViewModel
    @State var person: User?
    @State var message = Message(id: "", text: "", senderId: "", timestamp: Date())
    let formater = DateFormatter()
    let chat: Chat

    let rowTapped: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "person")
                .padding(.trailing)
            VStack(alignment: .leading) {
                HStack {
                    Text(person?.name ?? "")
                    Spacer()
                    Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(message.text )
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 40)
            .onTapGesture {
                rowTapped()
            }
            .onAppear {
                self.viewModel.getUserByChat(chat: self.chat) { user in
                    withAnimation {
                        self.person = user
                    }
                }
                self.viewModel.getMessages(chatId: chat.id ?? "someId") { messages in
                    withAnimation {
                        self.message = messages.last ?? Message(id: "", text: "", senderId: "", timestamp: Date())
                    }
                }
            }
    }

}
