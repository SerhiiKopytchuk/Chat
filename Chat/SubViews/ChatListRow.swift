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

                Text(message.text )
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
                    .lineLimit(2)
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
            DispatchQueue.main.async {
                self.viewModel.getUserByChat(chat: self.chat) { user in
                    withAnimation {
                        self.person = user

                        let ref = Storage.storage().reference(withPath: user.id )
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

            self.messageViewModel.currentChat = self.chat

            self.messageViewModel.getMessages { messages in
                withAnimation {
                    self.message = messages.last ?? Message()
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
