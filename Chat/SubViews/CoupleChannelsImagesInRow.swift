//
//  CoupleChannesImagesInRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.02.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct CoupleChannelsImagesInRow: View {

    // MARK: - Variables
    private let imageSize: CGFloat = 30
    @State private var imageUrls: [URL?] = [URL(string: ""), URL(string: ""), URL(string: "")]
    @State private var showImage = false

    // MARK: - EnvironmentObjects
    @EnvironmentObject private var channelViewModel: ChannelViewModel

    // MARK: - body
    var body: some View {
        let chatsCount = min(3, channelViewModel.channels.count)
        HStack {
            HStack(spacing: -imageSize / 2.0) {
                ForEach(0..<chatsCount, id: \.self) { index in
                    channelImage(for: index)
                }

            }

            Text("\(channelViewModel.channels.count)")
                .font(.subheadline)
                .foregroundColor(Color.secondPrimary)
                .bold()
        }
    }

    // MARK: - ViewBuilders

    @ViewBuilder private func channelImage(for index: Int) -> some View {
        WebImage(url: imageUrls[index])
            .placeholder(content: {
                EmptyImageWithCharacterView(text: channelViewModel.channels[index].name ,
                                            colour: channelViewModel.channels[index].colour ,
                                            size: imageSize,
                                            font: .title3.bold())
            })
            .resizable()
            .scaledToFill()
            .frame(width: imageSize, height: imageSize)
            .cornerRadius(imageSize/2)
            .clipShape(Circle())
            .addLightShadow()
            .opacity(showImage ? 1 : 0)
            .onAppear {
                channelImageSetup(index: index)
            }
    }

    // MARK: - functions

    private func channelImageSetup(index: Int) {
        DispatchQueue.global(qos: .utility).async {
            let ref = StorageReferencesManager.shared
                .getChannelImageReference(channelId: channelViewModel.channels[index].id ?? "some id")
            ref.downloadURL { url, _ in
                DispatchQueue.main.async {
                    withAnimation(.easeOut) {
                        self.imageUrls[index] = url
                        showImage = true
                    }
                }
            }
        }
    }

}
