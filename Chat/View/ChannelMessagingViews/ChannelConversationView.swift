//
//  ChannelConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChannelConversationView: View {
    @State var currentUser: User

    @Namespace var animation

    @State var isExpandedProfile: Bool = false
    @State var profileImage: WebImage = WebImage(url: URL(string: ""))
    @State var loadExpandedContent = false
    @State var imageOffset: CGSize = .zero

    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    ChannelTitleRow(channel: channelViewModel.currentChannel,
                                    animationNamespace: animation,
                                    isExpandedProfile: $isExpandedProfile,
                                    profileImage: $profileImage,
                                    isOwner: currentUser.id == channelViewModel.currentChannel.ownerId
                    )
                        ScrollViewReader { _ in
                            ScrollView {
                                ForEach(
                                    self.channelMessagingViewModel.currentChannel.messages ?? [],
                                    id: \.id) { message in
                                        MessageBubble(message: message)
                                    }
                            }
                            .padding(.top, 10)
                            .background(.white)
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                        }
                        .ignoresSafeArea()
                }
                .background(Color("Peach"))
                if currentUser.id == channelViewModel.currentChannel.ownerId {
                    ChannelMessageField(channelMessagingViewModel: channelMessagingViewModel)
                }
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
            .matchedGeometryEffect(id: "channelPhoto", in: animation)
            .frame(height: 300)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top, content: {
            HStack(spacing: 10) {

                turnOffImageButton

                Text(channelViewModel.currentChannel.name)
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

struct ChannelConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelConversationView(currentUser: User(chats: [], channels: [], gmail: "gmail", id: "someId", name: "name"))
            .environmentObject(ChannelMessagingViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(ChannelViewModel())
    }
}
