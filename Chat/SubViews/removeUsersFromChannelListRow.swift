//
//  removeUsersFromChannelListRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.07.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct RemoveUsersFromChannelListRow: View {
    // MARK: - vars
    var user: String
    var userGmail: String
    var id: String
    var color: String

    @EnvironmentObject private var channelViewModel: ChannelViewModel
    @EnvironmentObject private var editChannelViewModel: EditChannelViewModel

    // MARK: image properties
    private let imageSize: CGFloat = 40
    @State private var imageUrl = URL(string: "")
    @State private var isFindUserImage = true

    // MARK: - body
    var body: some View {
        HStack {

            userImage

            // MARK: user name and gmail
            VStack(alignment: .leading) {
                Text(user)
                    .foregroundColor(.primary)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(userGmail)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()
            removeUserButton
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.secondPrimary)
        }
        .onAppear {
            imageStartSetup()
        }
    }

    // MARK: - viewBuilders

    @ViewBuilder private var userImage: some View {
        if isFindUserImage {
            WebImage(url: imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(imageSize/2)
                .addLightShadow()
                .padding()
        } else {
            EmptyImageWithCharacterView(text: user, colour: color, size: imageSize)
                .padding()
        }
    }

    @ViewBuilder private var removeUserButton: some View {
        Button {
            editChannelViewModel.removeChannelFromSubscriptionsWithCertainUser(id: self.id)
            withAnimation {
                editChannelViewModel.removeUserFromSubscribersList(id: self.id)
            }
            editChannelViewModel.getChannelSubscribers()

            self.updateChannelViewModel()
        } label: {
            Image(systemName: "minus")
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundColor(.blue.opacity(0.7))
                .addLightShadow()
                .padding()
        }
    }

    // MARK: - functions

    private func imageStartSetup() {
        let ref = StorageReferencesManager.shared.getProfileImageReference(userId: id)
        ref.downloadURL { url, err in
            if err != nil {
                self.isFindUserImage = false
                return
            }
            withAnimation(.easeInOut) {
                self.imageUrl = url
            }
        }
    }

    private func updateChannelViewModel() {
        channelViewModel.currentChannel = editChannelViewModel.currentChannel
    }
}
