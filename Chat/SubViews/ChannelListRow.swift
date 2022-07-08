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
    // Inject properties into the struct
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

    var body: some View {
        HStack {
            if isFindChannelImage {
                WebImage(url: imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.black, lineWidth: 1)
                            .shadow(radius: 5)
                    )
                    .padding(5)
                    .opacity(isShowImage ? 1 : 0)
            } else {
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.gray)
                    .clipped()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(5)
                    .opacity(isShowImage ? 1 : 0)
            }

            VStack(alignment: .leading) {
                HStack {
                    Text(channel.name )
                    Spacer()
                    Text("\(countOfMessages)" )
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(channel.description)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 40)
        .onTapGesture {
            rowTapped()
        }
        .contextMenu(menuItems: {
            Button(role: .destructive) {
                channelViewModel.currentChannel = self.channel

                if channel.ownerId == userViewModel.currentUser.id {
                    channelViewModel.deleteChannel()
                } else {
                    channelViewModel.removeChannelFromSubscriptions(id: self.channelViewModel.currentUser.id)
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
            DispatchQueue.main.async {
                let ref = Storage.storage().reference(withPath: self.channel.id ?? "SomeId")
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

            channelMessagingViewModel.currentChannel = self.channel

            channelMessagingViewModel.getMessages { messages in
                self.countOfMessages = messages.count
            }
        }
    }
}

struct ChannelListRow_Previews: PreviewProvider {
    static var previews: some View {
        ChannelListRow(channel: Channel(id: "id",
                                        name: "name",
                                        description: "description",
                                        ownerId: "ownerId",
                                        subscribersId: ["1", "2"],
                                        messages: [])) {
        }

    }
}
