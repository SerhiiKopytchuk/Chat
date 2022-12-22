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

    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
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
            guard let currentChannelId = channelViewModel.currentChannel.id else { return }
            imageViewModel.saveChannelMessageImage(image: newImage,
                                                   channelId: currentChannelId) { imageId in
//                channelMessagingViewModel.sendImage(imageId: imageId)
            }
        })
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
            UIApplication.shared.endEditing()
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
