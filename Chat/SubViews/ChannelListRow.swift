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
    // MARK: - vars
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel

    @State var channel: Channel

    @State private var countOfMessages = 0

    // MARK: messages properties
    @State private var imageUrl = URL(string: "")
    @State private var isFindChannelImage = true
    @State private var isShowImage = false
    private let imageSize: CGFloat = 50

    @ObservedObject private var channelMessagingViewModel = ChannelMessagingViewModel()

    let rowTapped: () -> Void

    // MARK: - body
    var body: some View {
        HStack {
            channelImage

            // MARK: name and description of channel
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
                .fill(Color.secondPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            rowTapped()
        }
        .contextMenu(menuItems: {
            contextButton
        })
        .onAppear {
            imageSetup()

            channelMessagingViewModel.currentChannel = self.channel

            channelMessagingViewModel.getMessagesCount { count in
                 self.countOfMessages = count
            }
        }
    }

    // MARK: - viewBuilders
    @ViewBuilder private var channelImage: some View {
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

    @ViewBuilder private var contextButton: some View {
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
    }

    // MARK: - functions
    private func imageSetup() {
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
