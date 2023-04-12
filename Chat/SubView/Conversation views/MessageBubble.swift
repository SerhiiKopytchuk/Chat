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

    var imageTapped: ( [URL], _ index: Int) -> Void

    @State private var isShowUnsentMark = false

    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var messagingViewModel: MessagingViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel

    // MARK: - Body
    var body: some View {
        VStack(alignment: message.isReply() ? .trailing : .leading) {

            addedEmojiView

            // MARK: message text or image
            ZStack(alignment: .bottomLeading) {
                if message.imagesId == [] && message.uiImages == nil {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(message.text)
                            .onAppear(perform: showUnsentMark)
                        unsentMark
                    }
                    .padding()
                    .foregroundColor(message.senderId != viewModel.currentUserUID ? .white : .primary)
                    .background(message.senderId != viewModel.currentUserUID ? .blue : Color.secondPrimary)
                    .cornerRadius(15, corners: message.senderId != viewModel.currentUserUID
                                  ? [.topLeft, .topRight, .bottomRight] : [.topLeft, .topRight, .bottomLeft])
                    .frame(alignment: message.isReply() ? .leading : .trailing)
                } else {
                    coupleImagesView
                }
                emojiBarView
            }

        }
        .padding(message.isReply() ? .trailing : .leading, 60)
        .padding(.horizontal, 10)
        .onAppear {
            addMessageSnapshotListener()
        }
    }

    // MARK: - viewBuilders

    @ViewBuilder private var coupleImagesView: some View {
        if message.imagesId != [] && message.uiImages == nil {
            CoupleImagesView(imagesId: message.imagesId?.sorted() ?? [],
                             uiImages: nil,
                             isChat: true,
                             isReceive: message.isReply()) { imagesURL, index in
                imageTapped(imagesURL, index)
            }
        } else {
            CoupleImagesView(imagesId: [],
                             uiImages: message.uiImages?.compactMap({ $0.image }),
                             isChat: true,
                             isReceive: message.isReply()) { _, _ in }
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

    @ViewBuilder private var unsentMark: some View {
        if messagingViewModel.unsentMessages.isContains(message: message) && isShowUnsentMark {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 12))
                .padding(.top, 4)
                .frame(alignment: .trailing)
                .foregroundColor(.gray)
        }
    }

    // MARK: - functions

    private func showUnsentMark() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isShowUnsentMark = true
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

struct MessageBubble_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        MessageBubble(message: Message(text: "Hello, how are you?",
                                       senderId: "id"),
                      showHighlight: .constant(false),
                      highlightedMessage: .constant(Message()),
                      imageTapped: { _, _ in })
            .environmentObject(UserViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChannelViewModel())
    }
}
