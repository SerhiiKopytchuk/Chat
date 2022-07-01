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
    @State var channel: Channel
    @State var imageUrl = URL(string: "")
    @State var isFindChannelImage = true
    @State var countOfMessages = 0

    @ObservedObject var channelMessagingViewModel = ChannelMessagingViewModel()

    let formater = DateFormatter()

    let rowTapped: () -> Void

    var body: some View {
        HStack {
            if isFindChannelImage {
                WebImage(url: imageUrl)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(5)
                    .onAppear {

                    }
            } else {
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.gray)
                    .clipped()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(5)
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
        .onAppear {
                withAnimation {
                    let ref = Storage.storage().reference(withPath: self.channel.id ?? "SomeId")
                    ref.downloadURL { url, err in
                        if err != nil {
                            self.isFindChannelImage = false
                            return
                        }
                        withAnimation(.easeInOut) {
                            self.imageUrl = url
                        }
                    }

                    channelMessagingViewModel.currentChannel = self.channel

                    channelMessagingViewModel.getMessages { messages in
                        self.countOfMessages = messages.count
                    }
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
