//
//  ChannelMessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI

struct ChannelMessageField: View {
    @State private var messageText = ""

    @State var height: CGFloat = 40

    @FocusState private var autoSizingTextFieldIsFocused: Bool

    @ObservedObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel

    var body: some View {
        HStack {
            ResizeableTextView(text: $messageText, height: $height, placeholderText: "Enter message")

            Button {
                messageText = messageText.trimmingCharacters(in: .newlines)
                channelMessagingViewModel.sendMessage(text: messageText)
                messageText = ""
                UIApplication.shared.endEditing()
                autoSizingTextFieldIsFocused = false
                channelViewModel.changeLastActivityAndSortChannels()

            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.gray)
                    .cornerRadius(15)
            }

        }
        .frame( height: height < 160 ? self.height : 160)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(15)
    }}

struct ChannelMessageField_Previews: PreviewProvider {
    static var previews: some View {
        ChannelMessageField(channelMessagingViewModel: ChannelMessagingViewModel())
    }
}
