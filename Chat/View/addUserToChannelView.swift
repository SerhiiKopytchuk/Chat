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
    @EnvironmentObject var userViewModel: UserViewModel

    @State var subscribersId: [String] = []

    var body: some View {
        VStack {
            HStack {
                TextField("Add users", text: $searchUserText)
                    .onChange(of: searchUserText, perform: { newText in
                        userViewModel.searchText = newText
                        userViewModel.getAllUsers()
                })
                .textFieldStyle(.roundedBorder)

                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)

            }
            .padding()

            usersList
                .onAppear {
                    self.subscribersId = channelViewModel.currentChannel.subscribersId ?? []
                }

            applyButton
                .padding()
        }.navigationTitle("Configure users")
            .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder var usersList: some View {
        List {
            ForEach(userViewModel.users, id: \.id) { user in
                AddUserCreateChannelRow(user: user.name,
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
            // logic
        } label: {
            Text("apply")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background( .orange)
                .cornerRadius(10)
                .shadow(color: .orange, radius: 3)
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
