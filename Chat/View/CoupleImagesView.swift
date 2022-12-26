//
//  CoupleImagesView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 22.12.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage

struct CoupleImagesView: View {

    // MARK: - Variables
    let imagesId: [String]
    let isChat: Bool
    let isReceive: Bool

    @State var isFindImage: Bool = false
    @State var imagesURL: [URL] = []

    var imageTapped: ([URL], _ index: Int) -> Void

    // MARK: - EnvironmentObjects

    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel

    // MARK: - body

    var body: some View {
        ZStack {
            if isFindImage {
                switch imagesId.count {
                case 1:
                    oneImageView()
                case 2:
                    twoImagesView()
                case 3:
                    threeImagesView()
                default:
                    oneImageView()
                }
            } else {
                ProgressView()
                    .frame(width: (UIScreen.main.bounds.width / 3 * 2 ), height: 250)
                    .aspectRatio(contentMode: .fill)
            }
        }
        .onAppear {
            imageSetup()
        }
        .cornerRadius(15, corners: isReceive
                      ? [.topLeft, .topRight, .bottomRight] :
                        [.topLeft, .topRight, .bottomLeft])
    }

    // MARK: - ViewBuilders

    @ViewBuilder func oneImageView() -> some View {
        imageView(imageIndex: 0, size: CGSize(width: (UIScreen.main.bounds.width / 3 * 2), height: 250))
    }

    @ViewBuilder func twoImagesView() -> some View {
        HStack(spacing: 2) {
            imageView(imageIndex: 0, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: 250))
            imageView(imageIndex: 1, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: 250))
        }
    }

    @ViewBuilder func threeImagesView() -> some View {
        HStack(spacing: 2) {
            imageView(imageIndex: 0, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: 250))

            VStack(spacing: 2) {
                imageView(imageIndex: 1, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: 250/2))
                imageView(imageIndex: 2, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: 250/2))
            }
        }
    }

    @ViewBuilder private func imageView(imageIndex: Int, size: CGSize) -> some View {
        WebImage(url: imagesURL[imageIndex], isAnimating: .constant(true))
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
            .clipped()
            .onTapGesture {
                imageTapped(imagesURL, imageIndex)
            }
    }

    // MARK: - functions

    private func imageSetup() {
        var chatId: String = ""
        var channelId: String = ""
        var references: [StorageReference] = []

        if isChat {
            chatId = messagingViewModel.currentChat.id ?? "chatID"
            imagesId.forEach { id in
                references.append(StorageReferencesManager.shared
                    .getChatMessageImageReference(chatId: chatId, imageId: id))
            }
        } else {
            channelId = channelViewModel.currentChannel.id ?? "channelID"
            imagesId.forEach { id in
                references.append(StorageReferencesManager.shared
                    .getChannelMessageImageReference(channelId: channelId, imageId: id))
            }
        }

        references.forEach { ref in
            ref.downloadURL { url, err in
                guard let url, err == nil else {
                    return
                }
                self.imagesURL.append(url)
                if imagesURL.count == imagesId.count {
                    withAnimation(.easeOut) {
                        self.isFindImage = true
                    }
                }
            }
        }
    }
}

#if DEBUG
struct CoupleImagesView_Previews: PreviewProvider {
    @Namespace static var animation
    static var previews: some View {
        CoupleImagesView(imagesId: [], isChat: true,
                         isReceive: true,
                         imageTapped: { _, _  in })
        .environmentObject(MessagingViewModel())
        .environmentObject(ChattingViewModel())
    }
}
#endif
