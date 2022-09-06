//
//  removeUsersFromChannelView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.07.2022.
//

import SwiftUI

struct RemoveUsersFromChannelView: View {

    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var editChannelViewModel: EditChannelViewModel
    @EnvironmentObject var userViewModel: UserViewModel

    @Environment(\.self) var env

    @State var subscribersId: [String] = []

    var body: some View {
        VStack {

            HeaderWithBackButton(environment: _env, text: "Remove users")
                .padding()

            usersList
                .padding()

        }
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder var usersList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(editChannelViewModel.channelSubscribers, id: \.id) { user in
                RemoveUsersFromChannelListRow(user: user.name,
                                        userGmail: user.gmail,
                                        id: user.id,
                                        color: user.colour
                )
                .environmentObject(channelViewModel)
                .environmentObject(editChannelViewModel)
            }
        }
        .padding(.horizontal)
    }
}

struct RemoveUsersFromChannelView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveUsersFromChannelView()
            .environmentObject(ChannelViewModel())
            .environmentObject(UserViewModel())
    }
}
