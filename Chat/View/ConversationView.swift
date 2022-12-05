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

    @Namespace private var profileImageNamespace
    @Namespace private var messageImageNamespace

    // MARK: fullscreen profile image properties
    @State private var isExpandedProfile: Bool = false
    @State var profileImageUrl = URL(string: "")
    @State private var loadExpandedContent = false
    @State private var imageOffset: CGSize = .zero
    @State private var isExpandedImageWithDelay = false
    @State var imageId = ""

    @State private var showMessageEmojiView: Bool = false
    @State var highlightMessage: Message?

    @State private var isExpandedImage: Bool = false
    @State private var messageImageURL = URL(string: "")

    @Environment(\.self) private var env

    @EnvironmentObject private var messagingViewModel: MessagingViewModel
    @EnvironmentObject private var chattingViewModel: ChattingViewModel

    // MARK: - body
    var body: some View {

        VStack(spacing: 0) {

            if !isExpandedImageWithDelay {
                titleRow
            }

            if isFindChat {
                VStack(spacing: 0) {
                    messagesScrollView

                    MessageField(messagingViewModel: messagingViewModel)
                        .ignoresSafeArea(.container, edges: .bottom)
                        .opacity(loadExpandedContent ? (1 - imageOffsetProgress()) : 1)
                        .opacity(isExpandedImage ? 0 : 1)
                }
                .background {
                    Rectangle()
                        .fill(.black)
                        .opacity(loadExpandedContent ? 1 : 0)
                        .ignoresSafeArea()
                }

            } else {
                createChatButton
            }
        }
        .addRightGestureRecognizer {
            if !isExpandedImage && !isExpandedProfile {
                env.dismiss()
            }
        }
        .navigationBarBackButtonHidden(loadExpandedContent)
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
            if isExpandedProfile {
                FullScreenImageCoverHeader( name: secondUser.name,
                                            animationHeaderImageNamespace: profileImageNamespace,
                                            namespaceId: "profilePhoto",
                                            isExpandedHeaderImage: $isExpandedProfile,
                                            imageOffset: $imageOffset,
                                            headerImageURL: profileImageUrl,
                                            loadExpandedContent: $loadExpandedContent)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - viewBuilders

    @ViewBuilder private var titleRow: some View {
        ConversationTitleRow(user: secondUser,
                             environment: _env,
                             animationNamespace: profileImageNamespace,
                             isFindChat: $isFindChat,
                             isExpandedProfile: $isExpandedProfile,
                             profileImageURL: $profileImageUrl
        )
        .addBlackOverlay(loadExpandedContent: loadExpandedContent,
                         imageOffsetProgress: imageOffsetProgress())
        .background {
            Color.secondPrimary
                .ignoresSafeArea()
        }
    }

    @ViewBuilder private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(
                        self.messagingViewModel.currentChat.messages ?? [],
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
        .addBlackOverlay(loadExpandedContent: loadExpandedContent,
                         imageOffsetProgress: isExpandedProfile ? imageOffsetProgress() : 1)
        .overlay {
            if isExpandedImage {
                FullScreenImageCoverMessage(
                    animationMessageImageNamespace: messageImageNamespace,
                    namespaceId: imageId,
                    isExpandedImage: $isExpandedImage,
                    isExpandedImageWithDelay: $isExpandedImageWithDelay,
                    imageOffset: $imageOffset,
                    messageImageURL: messageImageURL,
                    loadExpandedContent: $loadExpandedContent)
            }
        }
    }

    @ViewBuilder private func messageBubble(message: Message) -> some View {
        MessageBubble(message: message,
                      showHighlight: $showMessageEmojiView,
                      highlightedMessage: $highlightMessage,
                      animationNamespace: messageImageNamespace,
                      isHidden: $isExpandedImage,
                      extendedImageId: .constant(""),
                      imageTapped: { id, imageURl in

            self.imageId = id
            self.messageImageURL = imageURl

            withAnimation(.easeInOut) {
                self.isExpandedImage = true
                self.isExpandedImageWithDelay = true
            }

        })
        .accessibilityValue(message.imageId != "" ? "image" : "message")
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
                      animationNamespace: messageImageNamespace,
                      isHidden: $isExpandedImage,
                      extendedImageId: .constant(""),
                      imageTapped: {_, _ in})
        .padding(.top, highlightMessage.id == messagingViewModel.firstMessageId ? 10 : 0)
        .padding(.bottom, highlightMessage.id == messagingViewModel.lastMessageId ? 10 : 0)

        .environmentObject(messagingViewModel)
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

    private func imageOffsetProgress() -> CGFloat {
        let progress = imageOffset.height / 100
        if imageOffset.height < 0 {
            return 1
        } else {
            return 1  - (progress < 1 ? progress : 1)
        }
    }

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
