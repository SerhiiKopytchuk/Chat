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

    @Namespace var animation

    // MARK: fullscreen profile image properties
    @State private var isExpandedProfile: Bool = false
    @State private var profileImage: WebImage = WebImage(url: URL(string: ""))
    @State private var loadExpandedContent = false
    @State private var imageOffset: CGSize = .zero

    @State private var showMessageEmojiView: Bool = false
    @State var highlightMessage: Message?

    @Environment(\.self) private var env

    @EnvironmentObject private var messagingViewModel: MessagingViewModel
    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var chattingViewModel: ChattingViewModel

    // MARK: - body
    var body: some View {

        VStack(spacing: 0) {
            HeaderWithBackButton(environment: _env, text: "Chat")
                .frame(height: 10)
                .padding()
                .padding(.bottom)

            titleRow

            if isFindChat {
                VStack(spacing: 0) {
                    messagesScrollView

                    MessageField(messagingViewModel: messagingViewModel)
                        .ignoresSafeArea(.container, edges: .bottom)

                }
                .background {
                    Color.background
                        .ignoresSafeArea()
                }

            } else {
                createChatButton
            }
        }
        .addGradientBackground()
        .navigationBarBackButtonHidden(loadExpandedContent)
        .overlay(content: {
            if showMessageEmojiView {
                lightDarkEmptyBackground
            }
        })
        .overlayPreferenceValue(BoundsPreference.self) { values in
            if let highlightMessage = highlightMessage {
                if highlightMessage.isReply() {
                    if let preference = values.first(where: { item in
                        item.key == highlightMessage.id
                    }) {
                        GeometryReader { proxy in
                            let rect = proxy[preference.value]
                            MessageBubble(message: highlightMessage,
                                          showHighlight: $showMessageEmojiView,
                                          highlightedMessage: $highlightMessage,
                                          showEmojiBarView: true)
                            .padding(.top, highlightMessage.id == messagingViewModel.firstMessageId ? 10 : 0)
                            .padding(.bottom, highlightMessage.id == messagingViewModel.lastMessageId ? 10 : 0)

                            .environmentObject(messagingViewModel)
                            .id(highlightMessage.id)
                            .frame(width: rect.width, height: rect.height)
                            .offset(x: rect.minX, y: rect.minY)
                        }
                        .transition(.asymmetric(insertion: .identity, removal: .offset(x: 1)))
                    }
                }
            }
        }
        .overlay(content: {
            Rectangle()
                .fill(.black)
                .opacity(loadExpandedContent ? 1 : 0)
                .opacity(imageOffsetProgress())
                .ignoresSafeArea()
        })
        .overlay {
            if isExpandedProfile {
                expandedPhoto(image: profileImage)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - viewBuilders

    @ViewBuilder private var titleRow: some View {
        ConversationTitleRow(user: secondUser,
                             animationNamespace: animation,
                             isFindChat: $isFindChat,
                             isExpandedProfile: $isExpandedProfile,
                             profileImage: $profileImage
        )
        .background {
            Color.secondPrimary
                .opacity(0.5)
        }
        .environmentObject(chattingViewModel)
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

    @ViewBuilder private func expandedPhoto (image: WebImage ) -> some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
                profileImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(loadExpandedContent ? 0 : size.height)
                    .offset(y: loadExpandedContent ? imageOffset.height : .zero)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                imageOffset = value.translation
                            }).onEnded({ value in
                                let height = value.translation.height
                                if height > 0 && height > 100 {
                                    turnOffImageView()
                                } else {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        imageOffset = .zero
                                    }
                                }
                            })
                    )
            }
            .matchedGeometryEffect(id: "profilePhoto", in: animation)
            .frame(height: 300)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top, content: {
            HStack(spacing: 10) {

                turnOffImageButton

                Text(viewModel.secondUser.name)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer(minLength: 10)
            }
            .padding()
            .opacity(loadExpandedContent ? 1 : 0)
            .opacity(imageOffsetProgress())
        })
        .transition(.offset(x: 0, y: 1))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                loadExpandedContent = true
            }
        }
    }

    @ViewBuilder private var turnOffImageButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                loadExpandedContent = false
            }
            withAnimation(.easeInOut(duration: 0.3).delay(0.05)) {
                isExpandedProfile = false
            }

        } label: {
            Image(systemName: "arrow.left")
                .font(.title3)
                .foregroundColor(.white)
        }
    }

    @ViewBuilder private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(
                        self.messagingViewModel.currentChat.messages ?? [],
                        id: \.id) { message in
                            MessageBubble(message: message,
                                          showHighlight: $showMessageEmojiView,
                                          highlightedMessage: $highlightMessage)
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
                }
                .rotationEffect(Angle(degrees: 180))
            }
            .rotationEffect(Angle(degrees: 180))
            .background(Color.background)
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

    // MARK: - functions

    private func turnOffImageView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            loadExpandedContent = false
        }

        withAnimation(.easeInOut(duration: 0.3).delay(0.05)) {
            isExpandedProfile = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            imageOffset = .zero
        }
    }

    private func imageOffsetProgress() -> CGFloat {
        let progress = imageOffset.height / 100
        if imageOffset.height < 0 {
            return 1
        } else {
            return 1  - (progress < 1 ? progress : 1)
        }
    }

}
