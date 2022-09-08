//
//  ChannelMessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI

struct ChannelMessageField: View {
    // MARK: - Vars
    @State private var messageText = ""

    @State private var height: CGFloat = 40

    var sizeOfButtons: CGFloat = 20

    @ObservedObject var channelMessagingViewModel: ChannelMessagingViewModel
    @ObservedObject private var imageViewModel = ImageViewModel()
    @EnvironmentObject private var channelViewModel: ChannelViewModel

    @State var isShowingImagePicker = false
    @State var image: UIImage?

    // MARK: - body
    var body: some View {
        HStack {
            ResizeableTextView(text: $messageText, height: $height, placeholderText: "Enter message")

            imagePickerViewButton

            sendMessageButton

        }
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
        .onChange(of: image ?? UIImage(), perform: { newImage in
            imageViewModel.saveChannelMessageImage(image: newImage,
                                            channelId: channelViewModel.currentChannel.id ?? "channelId") { imageId in
                channelMessagingViewModel.sendImage(imageId: imageId)
            }
        })
        .frame( height: height < 160 ? self.height : 160)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
    }

    // MARK: - viewBuilders
    @ViewBuilder var imagePickerViewButton: some View {
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

    @ViewBuilder var sendMessageButton: some View {
        Button {
            messageText = messageText.trimmingCharacters(in: .newlines)
            channelMessagingViewModel.sendMessage(text: messageText)
            messageText = ""
            UIApplication.shared.endEditing()
            channelViewModel.changeLastActivityAndSortChannels()

        } label: {
            Image(systemName: "paperplane.fill")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.gray)
                .cornerRadius(15)
        }
    }
}

struct ChannelMessageField_Previews: PreviewProvider {
    static var previews: some View {
        ChannelMessageField(channelMessagingViewModel: ChannelMessagingViewModel())
    }
}
