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
    @Environment(\.self) var env

    @State var isExpandedProfile: Bool = false
    @State var profileImage: WebImage = WebImage(url: URL(string: ""))
    @State var loadExpandedContent = false
    @State var imageOffset: CGSize = .zero
    @State var isExpandedDetails = false
    @State var isGoToAddSubscribers = false
    @State var isGoToRemoveSubscribers = false
    @State var isGoToEditChannel = false

    @State var showHighlight: Bool = false
    @State var highlightMessage: Message?

    @Binding var isSubscribed: Bool

    @State var showingAlertOwner = false
    @State var showingAlertSubscriber = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var editChannelViewModel: EditChannelViewModel

    // MARK: - body

    var body: some View {
        ZStack {
            VStack {
                VStack {

                    HeaderWithBackButton(environment: _env, text: "Channel")
                        .padding()

                    ChannelTitleRow(channel: channelViewModel.currentChannel,
                                    animationNamespace: animation,
                                    isExpandedProfileImage: $isExpandedProfile,
                                    isExpandedDetails: $isExpandedDetails,
                                    profileImage: $profileImage,
                                    isOwner: currentUser.id == channelViewModel.currentChannel.ownerId
                    )
                    .background {
                        Color("BG")
                            .opacity(0.7)
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 5)

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
                    }

                    VStack(spacing: 0) {
                        messagesScrollView
                        if isSubscribed {
                            messagingTextField
                                .padding()
                        } else {
                            subscribeButton
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .background {
                        Color("BG")
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                            .ignoresSafeArea()
                    }
                }
                .frame(maxWidth: .infinity)

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
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .background {
            navigationLinks
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

    @ViewBuilder var navigationLinks: some View {
        NavigationLink(isActive: $isGoToAddSubscribers, destination: {
            AddUserToChannelView()
                .environmentObject(viewModel)
                .environmentObject(channelViewModel)
                .environmentObject(editChannelViewModel)
        }, label: { })
        .hidden()

        NavigationLink(isActive: $isGoToRemoveSubscribers, destination: {
            RemoveUsersFromChannelView()
                .environmentObject(viewModel)
                .environmentObject(channelViewModel)
                .environmentObject(editChannelViewModel)
        }, label: { })
        .hidden()

        NavigationLink(isActive: $isGoToEditChannel, destination: {
            EditChannelView(channelName: channelViewModel.currentChannel.name,
                            channelDescription: channelViewModel.currentChannel.description,
                            channelColor: channelViewModel.currentChannel.colour)
                .environmentObject(channelViewModel)
                .environmentObject(editChannelViewModel)
        }, label: { })
        .hidden()
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

    @ViewBuilder var ownerTitle: some View {
        HStack {
            Text("Owner: \(channelViewModel.currentChannel.ownerName)")
                .font(.callout)
            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }

    @ViewBuilder var countOfSubscribersTitle: some View {
        HStack {
            Text("Subscribers: \(channelViewModel.currentChannel.subscribersId?.count ?? 0)")
                .font(.callout)
            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }

    @ViewBuilder var addUsersToChannelButton: some View {
        Image(systemName: "plus")
            .foregroundColor(.gray)
            .padding(10)
            .background(.white)
            .cornerRadius(40)
            .addLightShadow()
            .onTapGesture {
                self.editChannelViewModelSetup()
                isGoToAddSubscribers.toggle()
            }
    }

    @ViewBuilder var unsubscribeUsersFromChannelButton: some View {
        Image(systemName: "minus")
            .frame(height: 15)
            .foregroundColor(.gray)
            .padding(10)
            .background(.white)
            .cornerRadius(40)
            .addLightShadow()
            .onTapGesture {
                self.editChannelViewModelSetup()
                editChannelViewModel.getChannelSubscribers()
                isGoToRemoveSubscribers.toggle()
            }
    }

    @ViewBuilder var editChannelButton: some View {
        Image(systemName: "pencil")
            .foregroundColor(.gray)
            .padding(10)
            .background(.white)
            .cornerRadius(40 )
            .addLightShadow()
            .onTapGesture {
                self.editChannelViewModelSetup()
                isGoToEditChannel.toggle()
            }
    }

    @ViewBuilder var removeOrDeleteChannelButton: some View {
        Image(systemName: "xmark")
            .foregroundColor(.gray)
            .padding(10)
            .background(.white)
            .cornerRadius(40 )
            .addLightShadow()
            .onTapGesture {
                if currentUser.id == channelViewModel.currentChannel.ownerId {
                    showingAlertOwner.toggle()
                } else {
                    showingAlertSubscriber.toggle()
                }
            }
    }

    @ViewBuilder var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(
                    self.channelMessagingViewModel.currentChannel.messages ?? [],
                    id: \.id) { message in
                        MessageBubble(message: message,
                                      showHighlight: .constant(false),
                                      highlightedMessage: .constant(Message()))
                        .frame(maxWidth: .infinity, alignment: message.isReply() ? .leading : .trailing)
                        .padding(.bottom,
                                     channelMessagingViewModel.currentChannel.messages?.last?.id == message.id ? 15 : 0)
                    }
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.horizontal, 12)
            .background(Color("BG"))
            .cornerRadius(30)

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
        .padding(.bottom, isOwner() ? 0 : 15)
        .ignoresSafeArea()
    }

    @ViewBuilder var messagingTextField: some View {
        if !isExpandedDetails {
            if currentUser.id == channelViewModel.currentChannel.ownerId {
                ChannelMessageField(channelMessagingViewModel: channelMessagingViewModel)
                    .environmentObject(channelViewModel)
            }
        }
    }

    @ViewBuilder var subscribeButton: some View {
        Button {
            channelViewModel.subscribeToChannel()
            self.isSubscribed = true
            channelViewModel.currentChannel.subscribersId?.append(viewModel.currentUser.id)
        } label: {
            Text("Subscribe")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
                .background(Color("BG"))
                .cornerRadius(15)
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

    // MARK: - functions

    func isOwner() -> Bool {
        return currentUser.id == channelViewModel.currentChannel.ownerId
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

    private func editChannelViewModelSetup() {
        editChannelViewModel.currentChannel = channelViewModel.currentChannel
        editChannelViewModel.currentUser = channelViewModel.currentUser
    }
}
