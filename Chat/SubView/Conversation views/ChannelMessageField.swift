//
//  ChannelMessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI
import PhotosUI

struct ChannelMessageField: View {
    // MARK: - Vars
    @State private var messageText = ""

    @State private var height: CGFloat = 40

    var sizeOfButtons: CGFloat = 20

    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
    @ObservedObject private var imageViewModel = ImageViewModel()
    @EnvironmentObject private var channelViewModel: ChannelViewModel

    @State var isShowingImagePicker = false
    @State private var selectedImages: [UIImage] = []

    // MARK: - body
    var body: some View {
        HStack {
            ResizeableTextView(text: $messageText, height: $height, placeholderText: "Enter message")

            imagePickerViewButton

            sendMessageButton

        }
        .sheet(isPresented: $isShowingImagePicker) {
            CustomImagePicker(onSelect: { assets in
                self.selectedImages = []
                parseImages(with: assets)
            },
                              isPresented: $isShowingImagePicker,
                              maxAmountOfImages: 3,
                              imagePickerModel: ImagePickerViewModel())
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
        .frame( height: height < 160 ? self.height : 160)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.secondPrimary)
    }

    // MARK: - viewBuilders
    @ViewBuilder var imagePickerViewButton: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            Image(systemName: "photo")
                .symbolRenderingMode(.hierarchical)
                .frame(width: sizeOfButtons, height: sizeOfButtons)
                .foregroundColor(.secondPrimary)
                .padding(10)
                .background(Color.primary.opacity(0.5))
                .cornerRadius(10)
        }
    }

    @ViewBuilder var sendMessageButton: some View {
        Button {
            messageText = messageText.trimmingCharacters(in: .newlines)
            channelMessagingViewModel.sendMessage(text: messageText)
            messageText = ""
            channelViewModel.changeLastActivityAndSortChannels()

        } label: {
            Image(systemName: "paperplane.fill")
                .symbolRenderingMode(.hierarchical)
                .frame(width: sizeOfButtons, height: sizeOfButtons)
                .foregroundColor(.secondPrimary)
                .padding(10)
                .background(Color.primary.opacity(0.5))
                .cornerRadius(10)
        }
    }

    // MARK: - functions

    func parseImages(with assets: [PHAsset]) {
        isShowingImagePicker = false

        let manager = PHCachingImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true

        DispatchQueue.global(qos: .userInteractive).async {
            assets.forEach { asset in
                manager.requestImage(for: asset,
                                     targetSize: .init(),
                                     contentMode: .default,
                                     options: options) { image, _ in
                    guard let image else { return }
                    DispatchQueue.main.async {
                        self.selectedImages.append(image)

                        if assets.count == selectedImages.count {
                            sendImages()
                        }
                    }
                }
            }
        }
    }

    func sendImages() {
        var imagesId: [String] = []
        selectedImages.forEach { _ in
            imagesId.append(UUID().uuidString)
        }

        var imageMessage: Message? = Message(images: selectedImages, senderId: channelViewModel.currentUser.id)
        let position = channelMessagingViewModel.currentChannel.messages?.count ?? 0

        DispatchQueue.main.async {
            channelMessagingViewModel.currentChannel.messages?.append(imageMessage ?? Message())
        }

        imageViewModel.saveChannel(images: selectedImages,
                                   imagesId: imagesId,
                                   channelId: channelViewModel.currentChannel.id) { result in

            if imageMessage != nil {
                channelMessagingViewModel.currentChannel.messages?.remove(at: position)
                imageMessage = nil
            }

            switch result {
            case .success:
                channelMessagingViewModel.send(imagesId: imagesId)
            case .failure(let error):
                print("failed to save channel images: \(error.localizedDescription)")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if imageMessage != nil {
                channelMessagingViewModel.currentChannel.messages?.remove(at: position)
                imageMessage = nil
            }
        }
    }
}

struct ChannelMessageField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {

            Spacer()

            ChannelMessageField()
                .environmentObject(ChannelViewModel())
                .environmentObject(ChannelMessagingViewModel())

        }
        .background(
            Color.gray
                .ignoresSafeArea()
        )

    }
}
