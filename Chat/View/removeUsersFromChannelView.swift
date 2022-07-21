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

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var subscribersId: [String] = []

    var body: some View {
        VStack {

            usersList
                .padding()

        }.navigationTitle("Remove users from channel")
            .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder var usersList: some View {
        List {
            ForEach(editChannelViewModel.channelSubscribers, id: \.id) { user in
                RemoveUsersFromChannelListRow(user: user.name,
                                        userGmail: user.gmail,
                                        id: user.id
                )
                .environmentObject(channelViewModel)
                .environmentObject(editChannelViewModel)
            }
        }
    }
}

struct RemoveUsersFromChannelView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveUsersFromChannelView()
            .environmentObject(ChannelViewModel())
            .environmentObject(UserViewModel())
    }
}
