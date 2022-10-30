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

    @Namespace private var animationProfileImage
    @Namespace private var animationMessageImage

    @Environment(\.self) var env

    @State private var isExpandedChannelImage: Bool = false
    @State private var channelImageURL = URL(string: "")

    @State private var isExpandedImage: Bool = false
    @State private var isExpandedImageWithDelay = false
    @State private var messageImageURL = URL(string: "")
    @State var imageId = ""

    @State private var loadExpandedContent = false
    @State private var imageOffset: CGSize = .zero

    @State private var isExpandedDetails = false
    @State private var isGoToAddSubscribers = false
    @State private var isGoToRemoveSubscribers = false
    @State private var isGoToEditChannel = false

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

            header

            messagesScrollView
                .ignoresSafeArea(.all, edges: .top)
                .frame(maxWidth: .infinity)
                .addBlackOverlay(loadExpandedContent: loadExpandedContent,
                                 imageOffsetProgress: imageOffsetProgress())
                .overlay {
                    if isExpandedImage {
                        FullScreenImageCoverMessage(animationMessageImageNamespace: animationMessageImage,
                                                    namespaceId: imageId,
                                                    isExpandedImage: $isExpandedImage,
                                                    isExpandedImageWithDelay: $isExpandedImageWithDelay,
                                                    imageOffset: $imageOffset,
                                                    messageImageURL: messageImageURL,
                                                    loadExpandedContent: $loadExpandedContent)
                    }
                }

            VStack(spacing: 0) {
                if isSubscribed {
                    messagingTextField
                        .ignoresSafeArea(.container, edges: .bottom)
                } else {
                    subscribeButton
                        .ignoresSafeArea(.container, edges: .bottom)
                }
            }
            .addBlackOverlay(loadExpandedContent: loadExpandedContent,
                             imageOffsetProgress: imageOffsetProgress())
        }
        .contentShape(Rectangle())
        .addRightGestureRecognizer {
            env.dismiss()
        }
        .navigationDestination(isPresented: $isGoToEditChannel, destination: {
            EditChannelView(channelName: channelViewModel.currentChannel.name,
                            channelDescription: channelViewModel.currentChannel.description,
                            channelColor: channelViewModel.currentChannel.colour)
        })
        .navigationDestination(isPresented: $isGoToAddSubscribers, destination: {
            AddUserToChannelView()
        })
        .navigationDestination(isPresented: $isGoToRemoveSubscribers, destination: {
            RemoveUsersFromChannelView()
        })
        .frame(maxWidth: .infinity)
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .overlay {
            if isExpandedChannelImage {
                FullScreenImageCoverHeader(animationHeaderImageNamespace: animationProfileImage,
                                           namespaceId: "channelPhoto",
                                           isExpandedHeaderImage: $isExpandedChannelImage,
                                           imageOffset: $imageOffset,
                                           headerImageURL: channelImageURL,
                                           loadExpandedContent: $loadExpandedContent)
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

    @ViewBuilder private var header: some View {
        if !isExpandedImageWithDelay {
            VStack(spacing: 0) {
                ChannelTitleRow(channel: channelViewModel.currentChannel,
                                environment: _env,
                                animationNamespace: animationProfileImage,
                                isExpandedProfileImage: $isExpandedChannelImage,
                                isExpandedDetails: $isExpandedDetails,
                                channelImageURL: $channelImageURL,
                                isOwner: currentUser.id == channelViewModel.currentChannel.ownerId
                )
                expandedDetails
            }
            .addBlackOverlay(loadExpandedContent: loadExpandedContent,
                             imageOffsetProgress: imageOffsetProgress())
            .background {
                Color.secondPrimary
                    .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder private var expandedDetails: some View {
        if isExpandedDetails {
            VStack(alignment: .leading) {

                HStack {
                    if isOwner() {
                        addUsersToChannelButton
                        unsubscribeUsersFromChannelButton
                        editChannelButton
                    }
                    removeOrDeleteChannelButton

                    Spacer()
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder private var addUsersToChannelButton: some View {
        Image(systemName: "plus")
            .foregroundColor(.primary.opacity(0.6))
            .padding(10)
            .background(Color.background)
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
            .background(Color.background)
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
            .background(Color.background)
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
            .background(Color.background)
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
                            messageBubble(message: message)
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

    @ViewBuilder private func messageBubble(message: Message) -> some View {
        ChannelMessageBubble(message: message,
                             animationNamespace: animationMessageImage,
                             isHidden: $isExpandedImage,
                             extendedImageId: $imageId) { id, imageUrl in

            self.imageId = id
            self.messageImageURL = imageUrl

            withAnimation(.easeInOut) {
                self.isExpandedDetails = false
                self.isExpandedImage = true
                self.isExpandedImageWithDelay = true
            }
        }
    }

    @ViewBuilder private var messagingTextField: some View {
        if !isExpandedDetails {
            if currentUser.id == channelViewModel.currentChannel.ownerId {
                ChannelMessageField()
                    .transition(.flipFromBottom)
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

    // MARK: - functions

    private func isOwner() -> Bool {
        return currentUser.id == channelViewModel.currentChannel.ownerId
    }

    private func editChannelViewModelSetup() {
        editChannelViewModel.currentChannel = channelViewModel.currentChannel
        editChannelViewModel.currentUser = channelViewModel.currentUser
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
