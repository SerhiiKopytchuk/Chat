//
//  ChannelConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI

struct ChannelConversationView: View {
    @State var currentUser: User

    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel

    var body: some View {
        VStack {
            VStack {
                ChannelTitleRow(channel: channelViewModel.currentChannel,
                                isOwner: currentUser.id == channelViewModel.currentChannel.ownerId)
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
        }
        .background(Color("Peach"))
        if currentUser.id == channelViewModel.currentChannel.ownerId {
            ChannelMessageField(channelMessagingViewModel: channelMessagingViewModel)
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
