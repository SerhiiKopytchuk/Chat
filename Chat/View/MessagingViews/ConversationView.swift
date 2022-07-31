//
//  ConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ConversationView: View {

// MARK: - vars
    @State var secondUser: User
    @Binding var isFindChat: Bool

    @Namespace var animation

    @State var isExpandedProfile: Bool = false
    @State var profileImage: WebImage = WebImage(url: URL(string: ""))
    @State var loadExpandedContent = false
    @State var imageOffset: CGSize = .zero

    @Environment(\.self) var env

    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    // MARK: - body
    var body: some View {
        ZStack {
            VStack {
                HeaderWithBackButton(environment: _env, text: "Chat")
                    .padding()

                VStack {
                    TitleRow(user: secondUser,
                             animationNamespace: animation,
                             isFindChat: $isFindChat,
                             isExpandedProfile: $isExpandedProfile,
                             profileImage: $profileImage
                    )
                    .background {
                        Color("BG")
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .environmentObject(chattingViewModel)

                    if isFindChat {
                        messagesScrollView
                        MessageField(messagingViewModel: messagingViewModel)
                    } else {
                        createChatButton
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(colors: [
                            Color("Gradient1"),
                            Color("Gradient2"),
                            Color("Gradient3")
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                .ignoresSafeArea()
            }
            .navigationBarBackButtonHidden(loadExpandedContent)
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
                        MessageBubble(message: message)
                    }
            }
            .padding(.top, 10)
            .background(Color("BG"))
            .cornerRadius(30)
            .onAppear {
                    proxy.scrollTo(self.messagingViewModel.lastMessageId, anchor: .bottom)
            }
            .onChange(of: self.messagingViewModel.lastMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
        .padding(.horizontal)
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

    func turnOffImageView() {
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

    func imageOffsetProgress() -> CGFloat {
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
        ConversationView(secondUser: User(),
                         isFindChat: .constant(true))
            .environmentObject(MessagingViewModel())
            .environmentObject(UserViewModel())
    }
}
