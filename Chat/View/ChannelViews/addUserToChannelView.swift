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

    @Environment(\.self) var presentationMode

    @State var subscribersId: [String] = []

    var body: some View {
        VStack {
            header

            addUsersTextField

            usersList

            applyButton
                .padding()
        }
        .background {
            Color("BG")
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder var header: some View {
        HStack(spacing: 15) {
            Button {
                presentationMode.dismiss()
            } label: {
                Image(systemName: "arrow.backward.circle.fill")
                    .toButtonLightStyle(size: 40)
            }

            Text("Add users")
                .font(.title.bold())
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }

    @ViewBuilder var addUsersTextField: some View {
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
        .padding(.top, 25)
        .padding()
    }

    @ViewBuilder var usersList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(editChannelViewModel.usersToAddToChannel, id: \.id) { user in
                AddUserToChannelRow(user: user.name,
                                        userGmail: user.gmail,
                                        id: user.id,
                                        subscribersId: $subscribersId
                )
                .environmentObject(channelViewModel)
            }
        }
        .padding(.horizontal)
    }

    var applyButton: some View {
        Button {
            editChannelViewModel.subscribeUsersToChannel(usersId: self.subscribersId)
            channelViewModel.currentChannel = editChannelViewModel.currentChannel
            editChannelViewModel.usersToAddToChannel = []
            self.subscribersId = []
            self.searchUserText = ""
            presentationMode.dismiss()
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
