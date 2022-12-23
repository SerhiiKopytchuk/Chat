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

struct ChatListRow: View {
    // MARK: - vars
    @EnvironmentObject private var viewModel: UserViewModel
    @ObservedObject private var messageViewModel = MessagingViewModel()
    @EnvironmentObject private var chattingViewModel: ChattingViewModel

    @State var person: User = User()
    @State fileprivate var message = Message()

    // MARK: image properties
    @State private var imageUrl = URL(string: "")
    @State private var isFindUserImage = true
    @State private var isShowImage = false
    private let imageSize: CGFloat = 50
    @State private var lastMessageImageUrl = URL(string: "")

    let chat: Chat

    let rowTapped: () -> Void

    // MARK: - body
    var body: some View {
        HStack {

            userImage

            VStack(alignment: .leading) {
                // MARK: name with last message date
                HStack {
                    Text(person.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                lastMessagePreview
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.secondPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            rowTapped()
        }
        .contextMenu(menuItems: {
            contextMenuButton
        })
        .onAppear {
            secondUserSetup()

            self.messageViewModel.currentChat = self.chat

            self.messageViewModel.getMessages { messages in
                withAnimation {
                    self.message = messages.last ?? Message()
                }
            }
        }
    }

    // MARK: - ViewBuilders
    @ViewBuilder private var userImage: some View {
        if isFindUserImage {
            WebImage(url: imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(imageSize/2)
                .clipShape(Circle())
                .opacity(isShowImage ? 1 : 0)
                .addLightShadow()
                .padding(5)
        } else {
            EmptyImageWithCharacterView(text: person.name ,
                                        colour: person.colour ,
                                        size: imageSize)
                .padding(5)
        }
    }

    @ViewBuilder private var lastMessagePreview: some View {
        if message.imagesId == [] {
            Text(message.text )
                .font(.caption)
                .italic()
                .foregroundColor(.secondary)
                .lineLimit(2)
        } else {
            WebImage(url: lastMessageImageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 20, height: 20)
                .cornerRadius(3)
                .onAppear {
                    lastMessageImageSetup()
                }
        }
    }

    @ViewBuilder private var contextMenuButton: some View {
        Button(role: .destructive) {
            chattingViewModel.currentChat = self.chat
            chattingViewModel.deleteChat()
        } label: {
            Label("remove chat", systemImage: "delete.left")
        }
    }

    // MARK: - functions
    private func lastMessageImageSetup() {
        let imageId: String = message.imagesId?.first ?? "imageId"

        let chatId: String = chat.id ?? "someID"
        let ref = StorageReferencesManager.shared
            .getChatMessageImageReference(chatId: chatId, imageId: imageId)

        ref.downloadURL { url, err in
            if err != nil {
                return
            }
            self.lastMessageImageUrl = url
        }
    }

    private func secondUserSetup() {
        DispatchQueue.main.async {
            self.viewModel.getUserByChat(chat: self.chat) { user in
                withAnimation {
                    self.person = user

                    let ref = StorageReferencesManager.shared.getProfileImageReference(userId: user.id)
                    ref.downloadURL { url, err in
                        if err != nil {
                            self.isFindUserImage = false
                            withAnimation(.easeInOut) {
                                self.isShowImage = true
                            }
                            return
                        }
                        withAnimation(.easeInOut) {
                            self.imageUrl = url
                            self.isShowImage = true
                        }
                    }
                }
            }
        }
    }
}

struct ChatListRow_Previews: PreviewProvider {
    static var previews: some View {

        ChatListRow(person: User(gmail: "some@gmail.com", id: "id", name: "serhii"),
                    chat: Chat(user1Id: "OCcDOefartfdWVenA5A8VFFMLXJ3",
                               user2Id: "x3Av8lCgiQWb4KvfJtaK7xY9g632",
                               lastActivityTimestamp: Date()),
                    rowTapped: {})
        .environmentObject(UserViewModel())
        .environmentObject(ChattingViewModel())

    }
}
