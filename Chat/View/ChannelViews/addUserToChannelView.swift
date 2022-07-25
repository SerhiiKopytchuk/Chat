//
//  addUserToChannelView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 16.07.2022.
//

import SwiftUI

struct AddUserToChannelView: View {

    @State var searchUserText = ""
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var editChannelViewModel: EditChannelViewModel
    @EnvironmentObject var userViewModel: UserViewModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var subscribersId: [String] = []

    var body: some View {
        VStack {
            HStack {
                TextField("Add users", text: $searchUserText)
                    .onChange(of: searchUserText, perform: { newText in
                        editChannelViewModel.searchText = newText
                        editChannelViewModel.getUsersToAddToChannel()
                })
                .textFieldStyle(.roundedBorder)

                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)

            }
            .padding()

            usersList

            applyButton
                .padding()
        }
        .navigationTitle("Add users to channel")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder var usersList: some View {
        List {
            ForEach(editChannelViewModel.usersToAddToChannel, id: \.id) { user in
                AddUserToChannelRow(user: user.name,
                                        userGmail: user.gmail,
                                        id: user.id,
                                        subscribersId: $subscribersId
                )
                .environmentObject(channelViewModel)
            }
        }
    }

    var applyButton: some View {
        Button {
            editChannelViewModel.subscribeUsersToChannel(usersId: self.subscribersId)
            channelViewModel.currentChannel = editChannelViewModel.currentChannel
            editChannelViewModel.usersToAddToChannel = []
            self.subscribersId = []
            self.searchUserText = ""
            presentationMode.wrappedValue.dismiss()
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
