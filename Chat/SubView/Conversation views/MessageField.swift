//
//  MessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import Foundation
import PhotosUI

struct MessageField: View {
    // MARK: - vars
    @State private var messageText: String = ""

    @State private var height: CGFloat = 40

    var sizeOfButtons: CGFloat = 20

    @ObservedObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var imageViewModel: ImageViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    @State private var isShowingImagePicker = false
    @State private var selectedImages: [UIImage] = []

    // MARK: - body
    var body: some View {
        HStack {

            ResizeableTextView(text: $messageText, height: $height, placeholderText: "Enter message")

            imagePickerButton

            sendMessageButton

        }
        .sheet(isPresented: $isShowingImagePicker, content: {
            CustomImagePicker(onSelect: { assets in
                self.selectedImages = []
                parseImages(with: assets)
            }, isPresented: $isShowingImagePicker,
                              maxAmountOfImages: 3,
                              imagePickerModel: ImagePickerViewModel())
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        })
        .frame( height: height < 160 ? self.height : 160)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.secondPrimary)
    }

    // MARK: - ViewBuilders
    @ViewBuilder private var imagePickerButton: some View {
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

    @ViewBuilder private var sendMessageButton: some View {
        Button {
            messageText = messageText.trimmingCharacters(in: .newlines)
            messagingViewModel.sendMessage(text: messageText)
            messageText = ""
            chattingViewModel.changeLastActivityAndSortChats()
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

    // MARK: - Functions

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
        var imageMessage: Message? = Message(images: selectedImages, senderId: chattingViewModel.currentUser.id)
        let position = messagingViewModel.currentChat?.messages?.count ?? 0
        DispatchQueue.main.async {
            messagingViewModel.currentChat?.messages?.append(imageMessage ?? Message())
        }

        imageViewModel.saveChat(images: selectedImages,
                                imagesId: imagesId,
                                chatId: chattingViewModel.currentChat?.id) { result in

            if imageMessage != nil {
                messagingViewModel.currentChat?.messages?.remove(at: position)
                imageMessage = nil
            }

            switch result {
            case .success:
                messagingViewModel.send(imagesId: imagesId)
            case .failure(let error):
                print("failed to save chat images: \(error.localizedDescription)")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if imageMessage != nil {
                messagingViewModel.currentChat?.messages?.remove(at: position)
                imageMessage = nil
            }
        }

    }
}

struct MessageField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {

            Spacer()

            MessageField(messagingViewModel: MessagingViewModel())
                .environmentObject(ImageViewModel())
                .environmentObject(ChattingViewModel())

        }
        .background(
            Color.gray
                .ignoresSafeArea()
        )

    }
}
