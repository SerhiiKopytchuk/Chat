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

    @Namespace private var animation
    @Environment(\.self) var env

    @State private var isExpandedProfile: Bool = false
    @State private var channelImage: WebImage = WebImage(url: URL(string: ""))
    @State private var loadExpandedContent = false
    @State private var imageOffset: CGSize = .zero
    @State private var isExpandedDetails = false
    @State private var isGoToAddSubscribers = false
    @State private var isGoToRemoveSubscribers = false
    @State private var isGoToEditChannel = false

    @State private var showHighlight: Bool = false
    @State private var highlightMessage: Message?

    @Binding var isSubscribed: Bool

    @State private var showingAlertOwner = false
    @State private var showingAlertSubscriber = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject private var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel
    @EnvironmentObject private var editChannelViewModel: EditChannelViewModel

    // MARK: - body

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HeaderWithBackButton(environment: _env, text: "Channel")
                    .padding()

                ChannelTitleRow(channel: channelViewModel.currentChannel,
                                animationNamespace: animation,
                                isExpandedProfileImage: $isExpandedProfile,
                                isExpandedDetails: $isExpandedDetails,
                                channelWebImage: $channelImage,
                                isOwner: currentUser.id == channelViewModel.currentChannel.ownerId
                )
                .background {
                    Color.secondPrimary
                        .opacity(0.5)
                }

                expandedDetails
            }
            .addGradientBackground()

            messagesScrollView
                .frame(maxWidth: .infinity)

            VStack(spacing: 0) {
                if isSubscribed {
                    messagingTextField
                        .ignoresSafeArea(.container, edges: .bottom)
                } else {
                    subscribeButton
                        .ignoresSafeArea(.container, edges: .bottom)
                }
            }

        }
        .navigationDestination(isPresented: $isGoToEditChannel, destination: {
            EditChannelView(channelName: channelViewModel.currentChannel.name,
                            channelDescription: channelViewModel.currentChannel.description,
                            channelColor: channelViewModel.currentChannel.colour)
            .environmentObject(channelViewModel)
            .environmentObject(editChannelViewModel)
        })
        .navigationDestination(isPresented: $isGoToAddSubscribers, destination: {
            AddUserToChannelView()
                .environmentObject(viewModel)
                .environmentObject(channelViewModel)
                .environmentObject(editChannelViewModel)
        })
        .navigationDestination(isPresented: $isGoToRemoveSubscribers, destination: {
            RemoveUsersFromChannelView()
                .environmentObject(viewModel)
                .environmentObject(channelViewModel)
                .environmentObject(editChannelViewModel)
        })
        .frame(maxWidth: .infinity)
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .overlay(content: {
            Rectangle()
                .fill(.black)
                .opacity(loadExpandedContent ? 1 : 0)
                .opacity(imageOffsetProgress())
                .ignoresSafeArea()
        })
        .overlay {
            if isExpandedProfile {
                expandedPhoto(image: channelImage)
            }
        }
        .alert("Do you really want to delete this channel?", isPresented: $showingAlertOwner) {
            Button("Delete", role: .destructive) {
                channelViewModel.deleteChannel()
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.red)
            Button("Cancel", role: .cancel) {}
        }
        .alert("Do you really want to unsubscribe from this channel?", isPresented: $showingAlertSubscriber) {
            Button("Unsubscribe", role: .destructive) {
                channelViewModel.removeChannelFromUserSubscriptions(id: self.channelViewModel.currentUser.id)
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.red)
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - viewBuilders

    @ViewBuilder private var expandedDetails: some View {
        if isExpandedDetails {
            VStack(alignment: .leading) {
                ownerTitle
                countOfSubscribersTitle

                HStack {
                    if isOwner() {
                        addUsersToChannelButton
                        unsubscribeUsersFromChannelButton
                        editChannelButton
                    }
                    removeOrDeleteChannelButton
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background {
                Color.secondPrimary
                    .opacity(0.5)
            }
            .transition(.push(from: .leading))
        }
    }

    @ViewBuilder private func expandedPhoto (image: WebImage ) -> some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
                channelImage
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

    @ViewBuilder private var ownerTitle: some View {
        HStack {
            Text("Owner: \(channelViewModel.currentChannel.ownerName)")
                .font(.callout)
            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }

    @ViewBuilder private var countOfSubscribersTitle: some View {
        HStack {
            Text("Subscribers: \(channelViewModel.currentChannel.subscribersId?.count ?? 0)")
                .font(.callout)
            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }

    @ViewBuilder private var addUsersToChannelButton: some View {
        Image(systemName: "plus")
            .foregroundColor(.primary.opacity(0.6))
            .padding(10)
            .background(Color.secondPrimary)
            .addLightShadow()
            .onTapGesture {
                self.editChannelViewModelSetup()
                isGoToAddSubscribers.toggle()
            }
            .clipShape(Circle())
    }

    @ViewBuilder private var unsubscribeUsersFromChannelButton: some View {
        Image(systemName: "minus")
            .frame(height: 15)
            .foregroundColor(.primary.opacity(0.6))
            .padding(10)
            .background(Color.secondPrimary)
            .addLightShadow()
            .onTapGesture {
                self.editChannelViewModelSetup()
                editChannelViewModel.getChannelSubscribers()
                isGoToRemoveSubscribers.toggle()
            }
            .clipShape(Circle())
    }

    @ViewBuilder private var editChannelButton: some View {
        Image(systemName: "pencil")
            .foregroundColor(.primary.opacity(0.6))
            .padding(10)
            .background(Color.secondPrimary)
            .addLightShadow()
            .onTapGesture {
                self.editChannelViewModelSetup()
                isGoToEditChannel.toggle()
            }
            .clipShape(Circle())
    }

    @ViewBuilder private var removeOrDeleteChannelButton: some View {
        Image(systemName: "xmark")
            .foregroundColor(.primary.opacity(0.6))
            .padding(10)
            .background(Color.secondPrimary)
            .addLightShadow()
            .onTapGesture {
                if currentUser.id == channelViewModel.currentChannel.ownerId {
                    showingAlertOwner.toggle()
                } else {
                    showingAlertSubscriber.toggle()
                }
            }
            .clipShape(Circle())
    }

    @ViewBuilder private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(
                        self.channelMessagingViewModel.currentChannel.messages ?? [],
                        id: \.id) { message in
                            MessageBubble(message: message,
                                          showHighlight: .constant(false),
                                          highlightedMessage: .constant(Message()),
                                          isChat: false)
                            .environmentObject(channelViewModel)
                            .padding(.top, message.id == channelMessagingViewModel.firstMessageId ? 10 : 0)
                            .padding(.bottom, message.id == channelMessagingViewModel.lastMessageId ? 10 : 0)
                            .id(message.id)
                            .frame(maxWidth: .infinity, alignment: message.isReply() ? .leading : .trailing)
                        }
                }
                .rotationEffect(Angle(degrees: 180))
            }
            .rotationEffect(Angle(degrees: 180))
            .padding(.horizontal, 12)
            .background(Color.background)

            .onAppear {
                proxy.scrollTo(self.channelMessagingViewModel.lastMessageId, anchor: .bottom)
            }
            .onChange(of: self.channelMessagingViewModel.lastMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }

    @ViewBuilder private var messagingTextField: some View {
        if !isExpandedDetails {
            if currentUser.id == channelViewModel.currentChannel.ownerId {
                ChannelMessageField(channelMessagingViewModel: channelMessagingViewModel)
                    .transition(.flipFromBottom)
                    .environmentObject(channelViewModel)
            }
        }
    }

    @ViewBuilder private var subscribeButton: some View {
        Button {
            channelViewModel.subscribeToChannel()
            withAnimation {
                self.isSubscribed = true
            }
            channelViewModel.currentChannel.subscribersId?.append(viewModel.currentUser.id)
        } label: {
            Text("Subscribe")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .background(Color.background)
                .ignoresSafeArea()
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

    // MARK: - functions

    private func isOwner() -> Bool {
        return currentUser.id == channelViewModel.currentChannel.ownerId
    }

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

    private func editChannelViewModelSetup() {
        editChannelViewModel.currentChannel = channelViewModel.currentChannel
        editChannelViewModel.currentUser = channelViewModel.currentUser
    }
}
