//
//  MessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import Foundation

struct MessageField: View {

    @State var messageText: String = ""

    @State var height: CGFloat = 40

    var sizeOfButtons: CGFloat = 20

    @FocusState private var autoSizingTextFieldIsFocused: Bool

    @ObservedObject var messagingViewModel: MessagingViewModel
    @ObservedObject var imageViewModel = ImageViewModel()
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    @State var isShowingImagePicker = false
    @State var image: UIImage?

    var body: some View {
        HStack {

            ResizeableTextView(text: $messageText, height: $height, placeholderText: "Enter message")

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
            .frame(maxHeight: .infinity, alignment: .bottom)

            Button {
                messageText = messageText.trimmingCharacters(in: .newlines)
                messagingViewModel.sendMessage(text: messageText)
                messageText = ""
                UIApplication.shared.endEditing()
                autoSizingTextFieldIsFocused = false
                chattingViewModel.changeLastActivityAndSortChats()
            } label: {
                Image(systemName: "paperplane.fill")
                    .frame(width: sizeOfButtons, height: sizeOfButtons)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.gray)
                    .cornerRadius(10)
            }

            .frame(maxHeight: .infinity, alignment: .bottom)

        }
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
        .onChange(of: image ?? UIImage(), perform: { newImage in
            imageViewModel.saveImage(image: newImage,
                                     chatId: chattingViewModel.currentChat.id ?? "some chat id") { imageId in
                messagingViewModel.sendImage(imageId: imageId)
            }
        })
        .frame( height: height < 160 ? self.height : 160)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(15)
    }

}
