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

    @Environment(\.self) var env

    @State private var isExpandedChannelImage: Bool = false
    @State private var channelImageURL = URL(string: "")

    @State private var isExpandedImage: Bool = false
    @State var messageImagesURL: [URL?] = []
    @State var imageIndex: Int = 0

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
        .addRightGestureRecognizer {
            if !isExpandedImage && !isExpandedChannelImage {
                env.dismiss()
            }
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
                ImageDetailedView(imagesURL: [channelImageURL], pageIndex: 0, isPresented: $isExpandedChannelImage)
            }
        }
        .overlay {
            if isExpandedImage {
                ImageDetailedView(imagesURL: messageImagesURL, pageIndex: imageIndex, isPresented: $isExpandedImage)
            }
        }
        .alert("Do you really want to delete this channel?", isPresented: $showingAlertOwner) {
            alertDeleteAndCancelChannelButton
        }
        .alert("Do you really want to unsubscribe from this channel?", isPresented: $showingAlertSubscriber) {
            alertUnsubscribeAndCancelChannelButton
        }
    }

    // MARK: - viewBuilders

    @ViewBuilder private var header: some View {
            VStack(spacing: 0) {
                ChannelTitleRow(channel: channelViewModel.currentChannel,
                                environment: _env,
                                isExpandedProfileImage: $isExpandedChannelImage,
                                isExpandedDetails: $isExpandedDetails,
                                channelImageURL: $channelImageURL,
                                isOwner: currentUser.id == channelViewModel.currentChannel.ownerId
                )
                expandedDetails
            }
            .background {
                Color.secondPrimary
                    .ignoresSafeArea()
            }
    }

    @ViewBuilder private var expandedDetails: some View {
        if isExpandedDetails {
            VStack(alignment: .leading) {

                HStack {
                    if isOwner {
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
                LazyVStack {
                    ForEach(
                        self.channelMessagingViewModel.currentChannel.messages ?? [],
                        id: \.id) { message in
                            messageBubble(message: message)
                        }
                }
                .frame(width: UIScreen.main.bounds.width)
                .rotationEffect(Angle(degrees: 180))
            }
            .scrollDismissesKeyboard(.immediately)
            .rotationEffect(Angle(degrees: 180))
            .padding(.horizontal, 12)
            .background(Color.background)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .onAppear {
                proxy.scrollTo(self.channelMessagingViewModel.lastMessageId, anchor: .bottom)
            }
            .onChange(of: self.channelMessagingViewModel.lastMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .frame(width: UIScreen.main.bounds.width)
        .ignoresSafeArea(.all, edges: [.leading, .trailing, .bottom])
    }

    @ViewBuilder private func messageBubble(message: Message) -> some View {
        ChannelMessageBubble(message: message) { imagesURL, index in
            self.messageImagesURL = imagesURL
            self.imageIndex = index

            withAnimation(.easeOut) {
                isExpandedImage = true
            }
        }
        .environmentObject(channelViewModel)
        .padding(.top, message.id == channelMessagingViewModel.firstMessageId ? 10 : 0)
        .padding(.bottom, message.id == channelMessagingViewModel.lastMessageId ? 10 : 0)
        .id(message.id)
        .frame(maxWidth: .infinity, alignment: message.isReply() ? .leading : .trailing)
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

    @ViewBuilder private var alertDeleteAndCancelChannelButton: some View {
        Button("Delete", role: .destructive) {
            channelViewModel.delete(channel: channelViewModel.currentChannel)
            presentationMode.wrappedValue.dismiss()
        }.foregroundColor(.red)
        Button("Cancel", role: .cancel) {}
    }

    @ViewBuilder private var alertUnsubscribeAndCancelChannelButton: some View {
        Button("Unsubscribe", role: .destructive) {
            channelViewModel.removeChannelFromUserSubscriptions(id: self.channelViewModel.currentUser.id)
            presentationMode.wrappedValue.dismiss()
        }.foregroundColor(.red)
        Button("Cancel", role: .cancel) {}
    }

    // MARK: - functions

    private var isOwner: Bool {
        return currentUser.id == channelViewModel.currentChannel.ownerId
    }

    private func editChannelViewModelSetup() {
        editChannelViewModel.currentChannel = channelViewModel.currentChannel
        editChannelViewModel.currentUser = channelViewModel.currentUser
    }
}

struct ChannelConversationView_Previews: PreviewProvider {
    @State static var channelViewModel = ChannelViewModel()
    @State static var channelMessagingViewModel = ChannelMessagingViewModel()
    static var previews: some View {
        ChannelConversationView(currentUser: User(gmail: "some@gmail.com", id: "id", name: "Name"),
                                isSubscribed: .constant(true))
            .environmentObject(UserViewModel())
            .environmentObject(channelViewModel)
            .environmentObject(channelMessagingViewModel)
            .environmentObject(EditChannelViewModel())
            .onAppear {
                self.channelViewModel.currentChannel = Channel(name: "Name",
                                                               description: "Description",
                                                               ownerId: "id",
                                                               ownerName: "ownerNae",
                                                               isPrivate: false)

                self.channelMessagingViewModel.currentChannel.messages?.append(Message(text: "Hello", senderId: "id"))
                self.channelMessagingViewModel.currentChannel.messages?
                    .append(Message(text: "How are you?", senderId: "id"))
            }
    }
}
