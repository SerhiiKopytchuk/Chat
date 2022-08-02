//
//  ChannelMessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI

struct ChannelMessageField: View {
    @State private var message = ""

    @ObservedObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel

    var body: some View {
        HStack {
            CustomTextField(placeholder: Text("Enter your message here"), text: $message)

            Button {
                channelMessagingViewModel.sendMessage(text: message)
                message = ""
                channelViewModel.getChannels(fromUpdate: true)
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.gray)
                    .cornerRadius(15)
            }

        }
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
