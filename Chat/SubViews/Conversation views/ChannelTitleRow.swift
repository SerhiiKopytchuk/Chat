//
//  ChannelTitleRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct ChannelTitleRow: View {
    // MARK: - vars

    var channel: Channel

    @Environment(\.self) var environment

    @Binding var isExpandedProfileImage: Bool
    @Binding var isExpandedDetails: Bool
    @Binding var channelImageURL: URL?

    @State var isOwner: Bool

    // MARK: image properties
    @State private var isFindUserImage = true
    private let imageSize: CGFloat = 50

    // MARK: - body
    var body: some View {
        HStack(spacing: 20) {

            Button {
                environment.dismiss()
            } label: {
                Image(systemName: "arrow.backward")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }

            channelImage

            // MARK: channel name and description
            VStack(alignment: .leading) {
                Text(channel.name)
                    .font(.title2).bold()
                    .lineLimit(isExpandedDetails ? 5 : 1)

                Text(channel.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(isExpandedDetails ? 5 : 1)

            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpandedDetails.toggle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                imageSetup()
            }
        }
        .padding()
    }

    // MARK: - ViewBuilders
    @ViewBuilder private var channelImage: some View {
        if isFindUserImage {
            VStack {
                if isExpandedProfileImage {
                    WebImage(url: channelImageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(imageSize/2)
                        .addLightShadow()
                        .opacity(0)
                } else {
                    WebImage(url: channelImageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(imageSize/2)
                        .addLightShadow()
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpandedProfileImage.toggle()
                }
            }
        } else {
            if let first = channel.name.first {
                Text(String(first.uppercased()))
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .frame(width: imageSize, height: imageSize)
                    .background {
                        Circle()
                            .fill(Color(channel.colour))
                    }
                    .addLightShadow()
            }
        }
    }

    // MARK: - functions

    private func imageSetup() {
        let ref = StorageReferencesManager.shared.getChannelImageReference(channelId: channel.id ?? "someId")

        ref.downloadURL { url, err in
            if err != nil {
                self.isFindUserImage = false
                return
            }
            withAnimation(.easeInOut) {
                self.channelImageURL = url
            }
        }
    }
}

struct ChannelTitleRow_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        ChannelTitleRow(channel: Channel(name: "Channel",
                                         description: "Description",
                                         ownerId: "ownerId",
                                         ownerName: "OwnerName",
                                         isPrivate: false),
                        isExpandedProfileImage: .constant(false),
                        isExpandedDetails: .constant(false),
                        channelImageURL: .constant(URL(string: "")),
                        isOwner: true)
    }
}
