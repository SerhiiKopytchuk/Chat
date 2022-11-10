//
//  removeUsersFromChannelView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.07.2022.
//

import SwiftUI

struct RemoveUsersFromChannelView: View {

    // MARK: - vars

    @EnvironmentObject private var channelViewModel: ChannelViewModel
    @EnvironmentObject private var editChannelViewModel: EditChannelViewModel

    @Environment(\.self) var env

    // MARK: - body
    var body: some View {
        VStack {

            HeaderWithBackButton(environment: _env, text: "Remove users")
                .padding()

            usersList

        }
        .addRightGestureRecognizer {
            env.dismiss()
        }
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }

    // MARK: - viewBuilders

    @ViewBuilder private var usersList: some View {
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
            .environmentObject(EditChannelViewModel())
    }
}
