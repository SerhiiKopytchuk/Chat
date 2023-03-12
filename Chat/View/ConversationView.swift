//
//  ConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import Foundation
import Combine

struct ConversationView: View {

    // MARK: - vars
    @State var secondUser: User
    @Binding var isFindChat: Bool

    // MARK: fullscreen profile image properties
    @State private var isExpandedProfile: Bool = false
    @State var profileImageUrl = URL(string: "")

    @State private var showMessageEmojiView: Bool = false
    @State var highlightMessage: Message?

    @State private var isExpandedImage: Bool = false
    @State var messageImagesURL: [URL?] = []
    @State var imageIndex: Int = 0

    @Environment(\.self) private var env

    @EnvironmentObject private var messagingViewModel: MessagingViewModel
    @EnvironmentObject private var chattingViewModel: ChattingViewModel

    // MARK: - body
    var body: some View {

        VStack(spacing: 0) {

            titleRow

            if isFindChat {
                VStack(spacing: 0) {
                    messagesScrollView

                    MessageField(messagingViewModel: messagingViewModel)
                        .ignoresSafeArea(.container, edges: .bottom)

                }
            } else {
                createChatButton
            }
        }
        .addRightGestureRecognizer {
            env.dismiss()
        }
        .overlay(content: {
            if showMessageEmojiView {
                lightDarkEmptyBackground
            }
        })
        .overlayPreferenceValue(BoundsPreference.self) { values in
            if let highlightMessage = highlightMessage, highlightMessage.isReply() {
                if let preference = values.first(where: { item in
                    item.key == highlightMessage.id
                }) {
                    GeometryReader { proxy in
                        let rect = proxy[preference.value]
                        highlightedMessageBubble(for: highlightMessage, rect: rect)
                    }
                    .transition(.asymmetric(insertion: .identity, removal: .offset(x: 1)))
                }
            }
        }
        .overlay {
            if isExpandedImage {
                ImageDetailedView(imagesURL: messageImagesURL,
                                  pageIndex: imageIndex,
                                  isPresented: $isExpandedImage)
            }
        }
        .overlay {
            if isExpandedProfile {
                ImageDetailedView(imagesURL: [profileImageUrl],
                                  pageIndex: 0,
                                  isPresented: $isExpandedProfile)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - viewBuilders

    @ViewBuilder private var titleRow: some View {
        ConversationTitleRow(user: secondUser,
                             environment: _env,
                             isFindChat: $isFindChat,
                             isExpandedProfile: $isExpandedProfile,
                             profileImageURL: $profileImageUrl
        )
        .background {
            Color.secondPrimary
                .ignoresSafeArea()
        }
    }

    @ViewBuilder private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(
                        self.messagingViewModel.currentChat?.messages ?? [],
                        id: \.id) { message in
                            messageBubble(message: message)
                        }
                }
                .rotationEffect(Angle(degrees: 180))
            }
            .rotationEffect(Angle(degrees: 180))
            .onAppear {
                proxy.scrollTo(self.messagingViewModel.lastMessageId, anchor: .bottom)
            }
            .onChange(of: self.messagingViewModel.lastMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
            .padding(.horizontal, 12)
        }
        .ignoresSafeArea(.all, edges: .top)
        .frame(maxWidth: .infinity)
        .background(Color.background)
    }

    @ViewBuilder private func messageBubble(message: Message) -> some View {
        MessageBubble(message: message,
                      showHighlight: $showMessageEmojiView,
                      highlightedMessage: $highlightMessage,
                      imageTapped: { imagesURl, index in

            self.imageIndex = index
            self.messageImagesURL = imagesURl

            withAnimation(.easeInOut.delay(0.05)) {
                self.isExpandedImage = true
            }

        })
        .accessibilityValue(message.imagesId != nil ? "image" : "message")
        .padding(.top, message.id == messagingViewModel.firstMessageId ? 10 : 0)
        .padding(.bottom, message.id == messagingViewModel.lastMessageId ? 10 : 0)
        .environmentObject(messagingViewModel)
        .id(message.id)
        .frame(maxWidth: UIScreen.main.bounds.width,
               alignment: message.isReply() ? .leading : .trailing)
        .anchorPreference(key: BoundsPreference.self, value: .bounds, transform: { anchor in
            return [(message.id  ?? "someId"): anchor]
        })
        .onLongPressGesture {
            if message.isReply() {
                withAnimation(.easeInOut) {
                    showMessageEmojiView = true
                    highlightMessage = message
                }

            }
        }
    }

    @ViewBuilder private func highlightedMessageBubble(for highlightMessage: Message, rect: CGRect) -> some View {
        MessageBubble(message: highlightMessage,
                      showHighlight: $showMessageEmojiView,
                      highlightedMessage: $highlightMessage,
                      showEmojiBarView: true,
                      imageTapped: {_, _  in})
        .padding(.top, highlightMessage.id == messagingViewModel.firstMessageId ? 10 : 0)
        .padding(.bottom, highlightMessage.id == messagingViewModel.lastMessageId ? 10 : 0)
        .id(highlightMessage.id)
        .frame(width: rect.width, height: rect.height)
        .offset(x: rect.minX, y: rect.minY)
    }

    @ViewBuilder private var createChatButton: some View {

        VStack {
            Button {
                chattingViewModel.createChat { chat in
                    messagingViewModel.currentChat = chat
                    messagingViewModel.getMessages(competition: { _ in })
                    withAnimation {
                        isFindChat = true
                    }
                    chattingViewModel.getChats(fromUpdate: true)
                }
            } label: {
                Text("Start Chat")
                    .font(.title)
                    .padding()
                    .background(.white)
                    .cornerRadius(20)
                    .addLightShadow()
            }
        }.frame(maxHeight: .infinity)

    }

    @ViewBuilder private var lightDarkEmptyBackground: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .ignoresSafeArea()
            .onTapGesture {
                highlightMessage = nil
                withAnimation(.easeInOut) {
                    showMessageEmojiView = false
                }
            }
    }

    // MARK: - functions

}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(secondUser: User(gmail: "some@gmail.com",
                                          id: "secondUserId",
                                          name: "secondUserName"),
                         isFindChat: .constant(true))
        .environmentObject(MessagingViewModel())
        .environmentObject(ChattingViewModel())
        .environmentObject(PresenceViewModel())

    }
}
