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
    var channel: Channel

    let animationNamespace: Namespace.ID
    @Binding var isExpandedProfileImage: Bool
    @Binding var isExpandedDetails: Bool
    @Binding var profileImage: WebImage

    @EnvironmentObject var channelViewModel: ChannelViewModel

    @State var isOwner: Bool

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    let imageSize: CGFloat = 50

    var body: some View {
        HStack(spacing: 20) {

            channelImage

            VStack(alignment: .leading) {
                Text(channel.name)
                    .font(.title).bold()
                    .lineLimit(isExpandedDetails ? 2 : 1)

                Text(channel.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(isExpandedDetails ? 2 : 1)

            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpandedDetails.toggle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                let ref = Storage.storage().reference(withPath: channel.id ?? "someId" )
                ref.downloadURL { url, err in
                    if err != nil {
                        self.isFindUserImage = false
                        return
                    }
                    withAnimation(.easeInOut) {
                        self.profileImage = WebImage(url: url)
                        self.imageUrl = url
                    }
                }
            }
        }
        .padding()
    }

    @ViewBuilder var channelImage: some View {
        if isFindUserImage {
            VStack {
                if isExpandedProfileImage {
                    WebImage(url: imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(imageSize/2)
                        .addLightShadow()
                        .opacity(0)
                } else {
                    WebImage(url: imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(imageSize/2)
                        .addLightShadow()
                        .matchedGeometryEffect(id: "channelPhoto", in: animationNamespace)
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
}
