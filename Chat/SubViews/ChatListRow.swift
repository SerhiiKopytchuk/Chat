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
    // Inject properties into the struct
    @EnvironmentObject var viewModel: UserViewModel
    @ObservedObject var messageViewModel = MessagingViewModel()
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    @State var person: User?
    @State var message = Message()
    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true
    @State var isShowImage = false

    @State var lastMessageImageUrl = URL(string: "")

    let formater = DateFormatter()
    let chat: Chat

    let imageSize: CGFloat = 50

    let rowTapped: () -> Void

    var body: some View {
        HStack {

            userImage

            VStack(alignment: .leading) {
                HStack {
                    Text(person?.name ?? "")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if message.imageId == "" {
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
                            let imageId: String = message.imageId ?? "imageId"

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
                }

            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            rowTapped()
        }
        .contextMenu(menuItems: {
            Button(role: .destructive) {
                chattingViewModel.currentChat = self.chat
                chattingViewModel.deleteChat()
            } label: {
                Label("remove chat", systemImage: "delete.left")
            }
        })
        .onAppear {
            imageSetup()

            self.messageViewModel.currentChat = self.chat

            self.messageViewModel.getMessages { messages in
                withAnimation {
                    self.message = messages.last ?? Message()
                }
            }
        }
    }

    private func imageSetup() {
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

    @ViewBuilder var userImage: some View {
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
            EmptyImageWithCharacterView(text: person?.name ?? "No Name",
                                        colour: person?.colour ?? String.getRandomColorFromAssets(),
                                        size: imageSize)
                .padding(5)
        }
    }

}
