//
//  addUserToChannelView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 16.07.2022.
//

import SwiftUI

struct AddUserToChannelView: View {

    // MARK: - vars
    @State private var searchUserText = ""
    @EnvironmentObject private var channelViewModel: ChannelViewModel
    @EnvironmentObject private var editChannelViewModel: EditChannelViewModel
    @EnvironmentObject private var userViewModel: UserViewModel

    @Environment(\.self) var env

    @State private var subscribersId: [String] = []

    // MARK: - body
    var body: some View {
        VStack {
            HeaderWithBackButton(environment: _env, text: "Add users")
                .padding(.vertical)
                .padding(.horizontal)

            addUsersTextField

            usersList

            applyButton
                .padding()
        }
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }

    // MARK: - viewBuilders

    @ViewBuilder private var addUsersTextField: some View {
        Label {
            TextField("Search users", text: $searchUserText)
                .padding(.leading, 10)
                .onChange(of: searchUserText, perform: { newText in
                    editChannelViewModel.searchText = newText
                    editChannelViewModel.getUsersToAddToChannel()
            })
        } icon: {
            Image(systemName: "magnifyingglass")
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white)
        }
        .padding(.top, 5)
        .padding()
    }

    @ViewBuilder private var usersList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(editChannelViewModel.usersToAddToChannel, id: \.id) { user in
                AddUserToChannelListRow(user: user.name,
                                        userGmail: user.gmail,
                                        id: user.id,
                                        colour: user.colour,
                                        subscribersId: $subscribersId
                )
                .environmentObject(channelViewModel)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder private var applyButton: some View {
        Button {
            editChannelViewModel.subscribeUsersToChannel(usersId: self.subscribersId)
            channelViewModel.currentChannel = editChannelViewModel.currentChannel
            editChannelViewModel.usersToAddToChannel = []
            self.subscribersId = []
            self.searchUserText = ""
            env.dismiss()
        } label: {
            Text("apply")
                .toButtonGradientStyle()
        }
    }

}

struct AddUserToChannelView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserToChannelView()
            .environmentObject(ChannelViewModel())
            .environmentObject(UserViewModel())
    }
}
