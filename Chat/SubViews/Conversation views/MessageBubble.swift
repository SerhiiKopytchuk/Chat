//
//  MessageBubble.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct MessageBubble: View {

    // MARK: - vars
    @State var message: Message
    @Binding var showHighlight: Bool
    @Binding var highlightedMessage: Message?
    @State var showEmojiBarView = false
    @State private var imageUrl = URL(string: "")

    @State var isFindImage = false
    @State private var imageHeight: CGFloat = 0
    @State private var imageWight: CGFloat = 0

    var isChat: Bool = true

    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var messagingViewModel: MessagingViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel

    // MARK: - Body
    var body: some View {
        VStack(alignment: message.isReply() ? .trailing : .leading) {

            addedEmojiView

            // MARK: message text or image
            ZStack(alignment: .bottomLeading) {
                if message.imageId == "" {
                    Text(message.text)
                        .padding()
                        .foregroundColor(message.senderId != viewModel.getUserUID() ? .white : .black)
                        .background(message.senderId != viewModel.getUserUID() ? .blue : Color.white)
                        .cornerRadius(15, corners: message.senderId != viewModel.getUserUID()
                                      ? [.topLeft, .topRight, .bottomRight] : [.topLeft, .topRight, .bottomLeft])
                        .frame(alignment: message.isReply() ? .leading : .trailing)
                } else {
                    imageView
                }

                emojiBarView
            }
            .frame(alignment: message.isReply() ? .leading : .trailing)

        }
        .padding(message.isReply() ? .trailing : .leading, 60)
        .padding(.horizontal, 10)
        .onAppear {
            addMessageSnapshotListener()
        }
        .onTapGesture { }
    }

    // MARK: - viewBuilders
    @ViewBuilder private var imageView: some View {
        VStack {
            if isFindImage {
                WebImage(url: imageUrl, isAnimating: .constant(true))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .cornerRadius(15, corners: message.senderId != viewModel.getUserUID()
                                  ? [.topLeft, .topRight, .bottomRight] :
                                    [.topLeft, .topRight, .bottomLeft])
            } else {
                ProgressView()
                    .frame(width: 300, height: 250)
                    .aspectRatio(contentMode: .fill)
            }

        }
        .onAppear {
            imageSetup()
        }
    }

    @ViewBuilder private var addedEmojiView: some View {
        if message.isEmojiAdded() {
            AnimatedEmoji(emoji: message.emojiValue, color: message.isReply() ? Color("Gray") : .blue)
                .offset(x: message.isReply() ? 15 : -15)
                .padding(.bottom, -25)
                .zIndex(1)
                .opacity(showHighlight ? 0 : 1)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        if message.isReply() {
                            messagingViewModel.removeEmoji(message: message)
                        }
                    }
                }
        }
    }

    @ViewBuilder private var emojiBarView: some View {
        if showEmojiBarView {
            EmojiView(hideView: $showHighlight, message: message) { emoji in

                messagingViewModel.addEmoji(message: message, emoji: emoji)

                highlightedMessage = nil

                withAnimation(.easeInOut) {
                    showHighlight = false
                }

            }
            .frame(maxWidth: .infinity)
            .offset(y: 55)
        }
    }

    // MARK: - functions
    private func imageSetup() {

        let imageId: String = message.imageId ?? "imageId"
        var chatId: String = ""
        var channelId: String = ""
        var ref: StorageReference

        if isChat {
            chatId = messagingViewModel.currentChat.id ?? "chatID"
            ref = StorageReferencesManager.shared.getChatMessageImageReference(chatId: chatId, imageId: imageId)
        } else {
            channelId = channelViewModel.currentChannel.id ?? "channelID"
            ref = StorageReferencesManager.shared
                .getChannelMessageImageReference(channelId: channelId, imageId: imageId)
        }

        ref.downloadURL { url, err in
            if err != nil {
                return
            }
                self.imageUrl = url
            withAnimation {
                self.isFindImage = true
            }
        }
    }

    private func addMessageSnapshotListener() {
        messagingViewModel.addSnapshotListenerToMessage(messageId: message.id ?? "someId") { message in
            withAnimation(.easeInOut) {
                self.message = message
            }
        }
    }
}
