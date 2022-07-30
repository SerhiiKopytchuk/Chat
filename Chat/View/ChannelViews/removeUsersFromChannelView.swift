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
            header

            usersList
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
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "arrow.backward.circle.fill")
                    .toButtonLightStyle(size: 40)
            }

            Text("Remove users")
                .font(.title.bold())
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }

    @ViewBuilder var usersList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(editChannelViewModel.channelSubscribers, id: \.id) { user in
                RemoveUsersFromChannelListRow(user: user.name,
                                        userGmail: user.gmail,
                                        id: user.id
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
