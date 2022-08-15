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

    @State var isExpandedProfile: Bool = false
    @State var profileImage: WebImage = WebImage(url: URL(string: ""))
    @State var loadExpandedContent = false
    @State var imageOffset: CGSize = .zero

    @State var showMessageEmojiView: Bool = false
    @State var highlightMessage: Message?

    @State var messageText = ""

    @Environment(\.self) var env

    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    // MARK: - body
    var body: some View {
        ZStack {
            VStack {
                HeaderWithBackButton(environment: _env, text: "Chat")
                    .frame(height: 15)
                    .padding()

                VStack(spacing: 0) {
                    titleRow

                    if isFindChat {
                        VStack(spacing: 0) {
                            messagesScrollView
                            MessageField(messageText: $messageText,
                                         messagingViewModel: messagingViewModel)
                            .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .background {
                            Color("BG")
                                .ignoresSafeArea()
                        }

                    } else {
                        createChatButton
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .addGradientBackground()
            .navigationBarBackButtonHidden(loadExpandedContent)
        }
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

    @ViewBuilder var titleRow: some View {
        ConversationTitleRow(user: secondUser,
                             animationNamespace: animation,
                             isFindChat: $isFindChat,
                             isExpandedProfile: $isExpandedProfile,
                             profileImage: $profileImage
        )
        .background {
            Color("BG")
                .opacity(0.7)
        }
        .environmentObject(chattingViewModel)
    }

    @ViewBuilder var lightDarkEmptyBackground: some View {
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

    @ViewBuilder func expandedPhoto (image: WebImage ) -> some View {
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

    var turnOffImageButton: some View {
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

    @ViewBuilder var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                ForEach(
                    self.messagingViewModel.currentChat.messages ?? [],
                    id: \.id) { message in
                        MessageBubble(message: message,
                                      showHighlight: $showMessageEmojiView,
                                      highlightedMessage: $highlightMessage)
                        .padding(.top, message.id == messagingViewModel.firstMessageId ? 10 : 0)
                        .environmentObject(messagingViewModel)
                        .id(message.id)
                        .frame(maxWidth: .infinity, alignment: message.isReply() ? .leading : .trailing)
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
            .background(Color("BG"))
            .onAppear {
                proxy.scrollTo(self.messagingViewModel.lastMessageId, anchor: .bottom)
            }
            .onChange(of: self.messagingViewModel.lastMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
            .onChange(of: self.messageText) { _ in
                withAnimation {
                    proxy.scrollTo(self.messagingViewModel.lastMessageId, anchor: .bottom)
                }
            }
            .onAppear {
                // does this good solution to scroll down?
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,

                                                       object: nil, queue: .main) { _ in
                    var time = 0.0

                    while time <= 0.5 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                            proxy.scrollTo(self.messagingViewModel.lastMessageId, anchor: .bottom)
                        }
                        time += 0.0005
                    }

                }
            }
            .frame(alignment: .bottom)
            .padding(.horizontal, 12)
        }
    }

    @ViewBuilder var createChatButton: some View {

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
