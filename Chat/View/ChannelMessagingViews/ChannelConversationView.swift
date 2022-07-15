//
//  ChannelConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChannelConversationView: View {

    // MARK: - vars
    @State var currentUser: User

    @Namespace var animation

    @State var isExpandedProfile: Bool = false
    @State var profileImage: WebImage = WebImage(url: URL(string: ""))
    @State var loadExpandedContent = false
    @State var imageOffset: CGSize = .zero
    @State var isExpandedDetails = false

    @Binding var isSubscribed: Bool

    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel

    // MARK: - body
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    ChannelTitleRow(channel: channelViewModel.currentChannel,
                                    animationNamespace: animation,
                                    isExpandedProfile: $isExpandedProfile,
                                    isExpandedDetails: $isExpandedDetails,
                                    profileImage: $profileImage,
                                    isOwner: currentUser.id == channelViewModel.currentChannel.ownerId
                    )
                    if isExpandedDetails {
                        VStack(alignment: .leading) {
                            Group {
                                HStack {
                                    Text("Owner: \(channelViewModel.currentChannel.ownerName)")
                                        .font(.callout)
                                    Spacer()
                                }
                                HStack {
                                    Text("Subscribers: \(channelViewModel.currentChannel.subscribersId?.count ?? 0)")
                                        .font(.callout)
                                    Spacer()
                                }
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 15)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    messagesScrollView
                }
                .frame(maxWidth: .infinity)
                .background(Color("Peach"))
                if isSubscribed {
                    if !isExpandedDetails {
                        if currentUser.id == channelViewModel.currentChannel.ownerId {
                            ChannelMessageField(channelMessagingViewModel: channelMessagingViewModel)
                                .environmentObject(channelViewModel)
                        }
                    }
                } else {
                    Button {
                        channelViewModel.subscribeToChannel()
                        self.isSubscribed = true
                        channelViewModel.currentChannel.subscribersId?.append(viewModel.currentUser.id)
                    } label: {
                        Text("Subscribe")
                            .font(.title3)
                            .background(.white)
                            .cornerRadius(30)
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .navigationBarBackButtonHidden(loadExpandedContent)
        }
        .frame(maxWidth: .infinity)
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

    @ViewBuilder var messagesScrollView: some View {
        ScrollViewReader { proxy in
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
            .onAppear {
                withAnimation {
                    proxy.scrollTo(self.channelMessagingViewModel.lastMessageId, anchor: .bottom)
                }
            }
            .onChange(of: self.channelMessagingViewModel.lastMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
        .ignoresSafeArea()
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
