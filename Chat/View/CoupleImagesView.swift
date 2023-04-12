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
    let uiImages: [UIImage]?
    let isChat: Bool
    let isReceive: Bool

    @State var isFindImage: Bool = false
    @State var imagesURL: [URL] = []

    var imageTapped: ([URL], _ index: Int) -> Void

    private let imageHeight: CGFloat = 250

    // MARK: - EnvironmentObjects

    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel

    // MARK: - body

    var body: some View {
        ZStack {
            if uiImages == nil {
                if isFindImage {
                    imageView()
                } else {
                    ProgressView()
                        .frame(width: (UIScreen.main.bounds.width / 3 * 2 ), height: imageHeight)
                        .aspectRatio(contentMode: .fill)
                }
            } else {
                uiImagesView()
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

    @ViewBuilder
    private func imageView() -> some View {
        if imagesId.count == 1 {
            oneImageView()
        } else if imagesId.count == 2 {
            twoImagesView()
        } else if imagesId.count == 3 {
            threeImagesView()
        } else {
            oneImageView()
        }
    }

    @ViewBuilder private func oneImageView() -> some View {
        imageView(imageIndex: 0, size: CGSize(width: (UIScreen.main.bounds.width / 3 * 2), height: imageHeight))
    }

    @ViewBuilder private func twoImagesView() -> some View {
        HStack(spacing: 2) {
            imageView(imageIndex: 0, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: imageHeight))
            imageView(imageIndex: 1, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: imageHeight))
        }
    }

    @ViewBuilder private func threeImagesView() -> some View {
        HStack(spacing: 2) {
            imageView(imageIndex: 0, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: imageHeight))

            VStack(spacing: 2) {
                imageView(imageIndex: 1, size: CGSize(width: (UIScreen.main.bounds.width / 3),
                                                      height: (imageHeight - 2)/2))
                imageView(imageIndex: 2, size: CGSize(width: (UIScreen.main.bounds.width / 3),
                                                      height: (imageHeight - 2)/2))
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

    @ViewBuilder
    private func uiImagesView() -> some View {
        let imagesCount = uiImages?.count ?? 1

        if imagesCount == 1 {
            oneUIImageView()
        } else if imagesCount == 2 {
            twoUIImagesView()
        } else if imagesCount == 3 {
            threeUIImagesView()
        } else {
            oneUIImageView()
        }
    }

    @ViewBuilder private func oneUIImageView() -> some View {
        uiImageView(imageIndex: 0, size: CGSize(width: (UIScreen.main.bounds.width / 3 * 2), height: imageHeight))
    }

    @ViewBuilder private func twoUIImagesView() -> some View {
        HStack(spacing: 2) {
            uiImageView(imageIndex: 0, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: imageHeight))
            uiImageView(imageIndex: 1, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: imageHeight))
        }
    }

    @ViewBuilder private func threeUIImagesView() -> some View {
        HStack(spacing: 2) {
            uiImageView(imageIndex: 0, size: CGSize(width: (UIScreen.main.bounds.width / 3), height: imageHeight))

            VStack(spacing: 2) {
                uiImageView(imageIndex: 1, size: CGSize(width: (UIScreen.main.bounds.width / 3),
                                                      height: (imageHeight - 2)/2))
                uiImageView(imageIndex: 2, size: CGSize(width: (UIScreen.main.bounds.width / 3),
                                                      height: (imageHeight - 2)/2))
            }
        }
    }

    @ViewBuilder private func uiImageView(imageIndex: Int, size: CGSize) -> some View {
        if let uiImage = uiImages?[imageIndex] {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .contentShape(Rectangle())
                .clipped()
                .overlay {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    ProgressView()
                        .frame(width: (UIScreen.main.bounds.width / 3 * 2 ), height: imageHeight)
                        .aspectRatio(contentMode: .fill)
                }
        }
    }

    // MARK: - functions

    private func imageSetup() {
        var chatId: String = ""
        var channelId: String = ""
        var references: [StorageReference] = []

        if isChat {
            chatId = messagingViewModel.currentChat?.id ?? "chatID"
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
        CoupleImagesView(imagesId: [],
                         uiImages: nil,
                         isChat: true,
                         isReceive: true,
                         imageTapped: { _, _  in })
        .environmentObject(MessagingViewModel())
        .environmentObject(ChattingViewModel())
    }
}
#endif
