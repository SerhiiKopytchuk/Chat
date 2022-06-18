//
//  ConversationListRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.05.2022.
//
import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import SDWebImageSwiftUI

struct ConversationListRow: View {
    // Inject properties into the struct
    @EnvironmentObject var viewModel: AppViewModel
    @ObservedObject var messageViewModel = MessagingViewModel()
    @State var person: User?
    @State var message = Message(id: "", text: "", senderId: "", timestamp: Date())
    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    let formater = DateFormatter()
    let chat: Chat

    let rowTapped: () -> Void

    var body: some View {
        HStack {
            if isFindUserImage {
                WebImage(url: imageUrl)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(5)
                    .onAppear {

                    }
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(5)
            }

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

                        let ref = Storage.storage().reference(withPath: user.id )
                        ref.downloadURL { url, err in
                            if err != nil {
                                self.isFindUserImage = false
                                return
                            }
                            withAnimation(.easeInOut) {
                                self.imageUrl = url
                            }
                        }
                    }
                }
                self.messageViewModel.currentChat = self.chat
                self.messageViewModel.getMessages(){ messages in
                    withAnimation {
                        self.message = messages.last ?? Message(id: "", text: "", senderId: "", timestamp: Date())
                    }
                }
            }
    }

}
