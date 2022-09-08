//
//  MessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import Foundation

struct MessageField: View {
    // MARK: - vars
    @State private var messageText: String = ""

    @State private var height: CGFloat = 40

    var sizeOfButtons: CGFloat = 20

    @ObservedObject var messagingViewModel: MessagingViewModel
    @ObservedObject private var imageViewModel = ImageViewModel()
    @EnvironmentObject private var chattingViewModel: ChattingViewModel

    @State private var isShowingImagePicker = false
    @State private var image: UIImage?

    // MARK: - body
    var body: some View {
        HStack {

            ResizeableTextView(text: $messageText, height: $height, placeholderText: "Enter message")

            imagePickerButton

            sendMessageButton

        }
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
        .onChange(of: image ?? UIImage(), perform: { newImage in
            imageViewModel.saveChatImage(image: newImage,
                                     chatId: chattingViewModel.currentChat.id ?? "some chat id") { imageId in
                messagingViewModel.sendImage(imageId: imageId)
            }
        })
        .frame( height: height < 160 ? self.height : 160)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.white)
    }

    // MARK: - ViewBuilders
    @ViewBuilder private var imagePickerButton: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            Image(systemName: "photo")
                .frame(width: sizeOfButtons, height: sizeOfButtons)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.gray)
                .cornerRadius(10)
        }
    }

    @ViewBuilder private var sendMessageButton: some View {
        Button {
            messageText = messageText.trimmingCharacters(in: .newlines)
            messagingViewModel.sendMessage(text: messageText)
            messageText = ""
            UIApplication.shared.endEditing()
            chattingViewModel.changeLastActivityAndSortChats()
        } label: {
            Image(systemName: "paperplane.fill")
                .frame(width: sizeOfButtons, height: sizeOfButtons)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.gray)
                .cornerRadius(10)
        }
    }

}
