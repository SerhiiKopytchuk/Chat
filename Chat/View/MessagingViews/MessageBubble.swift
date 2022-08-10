//
//  MessageBubble.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI

struct MessageBubble: View {

    @State var message: Message
    @Binding var showHighlight: Bool
    @Binding var highlightedMessage: Message?
    @State var showEmojiBarView = false

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel

    var body: some View {
        VStack(alignment: message.isReply() ? .trailing : .leading) {

            addedEmojiView

            ZStack(alignment: .bottomLeading) {

                Text(message.text)
                    .padding()
                    .foregroundColor(message.senderId != viewModel.getUserUID() ? .white : .black)
                    .background(message.senderId != viewModel.getUserUID() ? .blue : Color.white)
                    .cornerRadius(15, corners: message.senderId != viewModel.getUserUID()
                                  ? [.topLeft, .topRight, .bottomRight] : [.topLeft, .topRight, .bottomLeft])
                    .frame(alignment: message.isReply() ? .leading : .trailing)

                emojiBarView
            }
            .frame(alignment: message.isReply() ? .leading : .trailing)

        }
        .padding(message.isReply() ? .trailing : .leading, 60)
        .padding(.horizontal, 10)
        .onAppear {
            messagingViewModel.addSnapshotListenerToMessage(messageId: message.id ?? "someId") { message in
                withAnimation(.easeInOut) {
                    self.message = message
                }
            }
        }
        .onTapGesture { }
    }

    @ViewBuilder var addedEmojiView: some View {
        if message.isEmojiAdded {
            AnimatedEmoji(emoji: message.emojiValue, color: message.isReply() ? Color("Gray") : .blue)
                .offset(x: message.isReply() ? 15 : -15)
                .padding(.bottom, -25)
                .zIndex(1)
                .opacity(showHighlight ? 0 : 1)
        }
    }

    @ViewBuilder var emojiBarView: some View {
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
}
