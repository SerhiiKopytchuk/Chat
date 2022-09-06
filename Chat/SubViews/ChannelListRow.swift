//
//  ChannelListRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import SDWebImageSwiftUI

struct ChannelListRow: View {

    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel

    @State var channel: Channel
    @State var imageUrl = URL(string: "")
    @State var isFindChannelImage = true
    @State var countOfMessages = 0
    @State var isShowImage = false

    @ObservedObject var channelMessagingViewModel = ChannelMessagingViewModel()

    let formater = DateFormatter()

    let rowTapped: () -> Void

    let imageSize: CGFloat = 50

    var body: some View {
        HStack {
            channelImage

            VStack(alignment: .leading) {
                Text(channel.name )
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(channel.description)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()

            RollingText(font: .caption,
                        weight: .light,
                        value: $countOfMessages)
            .foregroundColor(.secondary)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            rowTapped()
        }
        .contextMenu(menuItems: {
            Button(role: .destructive) {
                channelViewModel.currentChannel = self.channel

                if channel.ownerId == userViewModel.currentUser.id {
                    channelViewModel.deleteChannel()
                } else {
                    channelViewModel.removeChannelFromUserSubscriptions(id: self.channelViewModel.currentUser.id)
                }

            } label: {
                if channel.ownerId == userViewModel.currentUser.id {
                    Label("delete channel", systemImage: "delete.left")
                } else {
                    Label("unsubscribe", systemImage: "delete.left")
                }
            }
        })
        .onAppear {
            imageSetup()

            channelMessagingViewModel.currentChannel = self.channel

            channelMessagingViewModel.getMessagesCount { count in
                 self.countOfMessages = count
            }
        }
    }

    @ViewBuilder var channelImage: some View {
        if channel.id == channelViewModel.lastCreatedChannelId && channelViewModel.isSavedImage {
            Image(uiImage: channelViewModel.createdChannelImage ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(imageSize/2)
                .clipShape(Circle())
                .opacity(isShowImage ? 1 : 0)
                .addLightShadow()
                .padding(5)
                .padding(.trailing)
        } else if isFindChannelImage {
            WebImage(url: imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(imageSize/2)
                .clipShape(Circle())
                .opacity(isShowImage ? 1 : 0)
                .addLightShadow()
                .padding(5)
                .padding(.trailing)
        } else {

            EmptyImageWithCharacterView(text: channel.name, colour: channel.colour, size: imageSize)
                .padding(5)
                .padding(.trailing)

        }
    }

    func imageSetup() {
        DispatchQueue.main.async {
            let ref = StorageReferencesManager.shared.getChannelImageReference(channelId: channel.id ?? "some id")
            ref.downloadURL { url, err in
                if err != nil {
                    self.isFindChannelImage = false
                    withAnimation(.easeInOut) {
                        self.isShowImage = true
                    }
                    return
                }
                withAnimation(.easeInOut) {
                    self.imageUrl = url
                    self.isShowImage = true
                }
            }
        }
    }
}

struct ChannelListRow_Previews: PreviewProvider {
    static var previews: some View {
        ChannelListRow(channel: Channel()) { }
    }
}
