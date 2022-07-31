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
    var user: String
    var userGmail: String
    var id: String
    var color: String

    var imageSize: CGFloat = 40

    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var editChannelViewModel: EditChannelViewModel

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    var body: some View {
        HStack {

            userImage

            VStack(alignment: .leading) {
                Text(user)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(userGmail)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()
            Image(systemName: "minus")
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundColor(.blue.opacity(0.7))
                .addLightShadow()
                .padding()
                .onTapGesture {
                    editChannelViewModel.removeChannelFromSubscriptionsWithCertainUser(id: self.id)
                    withAnimation {
                        editChannelViewModel.removeUserFromSubscribersList(id: self.id)
                    }
                    editChannelViewModel.getChannelSubscribers()

                    self.updateChannelViewModel()
                }
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white)
        }
        .onAppear {
            let ref = Storage.storage().reference(withPath: self.id )
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
    }

    @ViewBuilder var userImage: some View {
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

    private func updateChannelViewModel() {
        channelViewModel.currentChannel = editChannelViewModel.currentChannel
        channelViewModel.channelSubscribers = editChannelViewModel.channelSubscribers
    }
}

struct RemoveUsersFromChannelListRow_Previews: PreviewProvider {
    static var previews: some View {
        RemoveUsersFromChannelListRow(user: "Koch",
                                userGmail: "koch@gmail.com",
                                id: "someId",
                                color: String.getRandomColorFromAssets()
        )
    }
}
