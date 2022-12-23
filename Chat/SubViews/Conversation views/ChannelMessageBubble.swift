//
//  MessageBubble.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct ChannelMessageBubble: View {

    // MARK: - vars
    @State var message: Message
    @State private var imageUrl = URL(string: "")

    @State var isFindImage = false

    let animationNamespace: Namespace.ID

    @Binding var isHidden: Bool
    @Binding var extendedImageId: String
    var imageTapped: (String, URL?) -> Void

    @State private var isShowUnsentMark = false

    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel

    // MARK: - Body
    var body: some View {
        VStack(alignment: message.isReply() ? .trailing : .leading) {

            // MARK: message text or image
            ZStack(alignment: .bottomLeading) {
                if message.imagesId != [] {
                    CoupleImagesView(imagesId: message.imagesId ?? [],
                                     isChat: false,
                                     isReceive: message.isReply()) { _, _, _ in

                    }
                } else {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(message.text)
                            .onAppear(perform: showUnsentMark)

                        unsentMark

                    }
                    .padding()
                    .foregroundColor(message.senderId != viewModel.currentUserUID ? .white : .primary)
                    .background(message.senderId != viewModel.currentUserUID ? .blue : Color.secondPrimary)
                    .cornerRadius(15, corners: message.senderId != viewModel.currentUserUID
                                  ? [.topLeft, .topRight, .bottomRight] : [.topLeft, .topRight, .bottomLeft])
                    .frame(alignment: message.isReply() ? .leading : .trailing)
                }
            }

        }
        .padding(message.isReply() ? .trailing : .leading, 60)
        .padding(.horizontal, 10)
        .opacity(extendedImageId == self.message.imagesId?.first ? (isHidden ? 0 : 1) : 1)
    }

    // MARK: - viewBuilders

    @ViewBuilder private var unsentMark: some View {
        if channelMessagingViewModel.unsentMessages.isContains(message: message) && isShowUnsentMark {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 12))
                .padding(.top, 4)
                .frame(alignment: .trailing)
                .foregroundColor(.gray)
        }
    }

    // MARK: - functions

    private func showUnsentMark() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isShowUnsentMark = true
            }
        }
    }
}

struct ChannelMessageBubble_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        ChannelMessageBubble(message: Message(text: "hello",
                                              senderId: "id"),
                             animationNamespace: namespace,
                             isHidden: .constant(false),
                             extendedImageId: .constant("")) { _, _ in
        }
                             .environmentObject(UserViewModel())
                             .environmentObject(ChannelViewModel())
                             .environmentObject(ChannelMessagingViewModel())
    }
}
