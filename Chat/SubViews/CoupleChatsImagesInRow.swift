//
//  CoupleChatsImagesRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 06.02.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct CoupleChatsImagesRow: View {

    // MARK: - Variables
    @State private var users: [User] = [User(), User(), User()]

    private let imageSize: CGFloat = 30
    @State private var imageUrls: [URL?] = [URL(string: ""), URL(string: ""), URL(string: "")]
    @State private var showImage = false

    // MARK: - EnvironmentObjects
    @EnvironmentObject private var chattingViewModel: ChattingViewModel
    @EnvironmentObject private var viewModel: UserViewModel

    // MARK: - body
    var body: some View {
        let chatsCount = min(3, chattingViewModel.chats.count)
        HStack {
            HStack(spacing: -imageSize / 2.0) {
                ForEach((0..<chatsCount).reversed(), id: \.self) { index in
                    userImage(for: index)
                }

            }

            Text("\(chattingViewModel.chats.count)")
                .font(.subheadline)
                .foregroundColor(Color.secondPrimary)
                .bold()
        }
    }

    // MARK: - ViewBuilders

    @ViewBuilder private func userImage(for index: Int) -> some View {
        WebImage(url: imageUrls[index])
            .placeholder(content: {
                EmptyImageWithCharacterView(text: users[index].name ,
                                            colour: users[index].colour ,
                                            size: imageSize,
                                            font: .title3.bold())
            })
            .resizable()
            .scaledToFill()
            .frame(width: imageSize, height: imageSize)
            .cornerRadius(imageSize/2)
            .clipShape(Circle())
            .addLightShadow()
            .opacity(showImage ? 1 : 0)
            .onAppear {
                secondUserSetup(index: index)
            }
    }

    // MARK: - functions

    private func secondUserSetup(index: Int) {
        DispatchQueue.global(qos: .utility).async {
            self.viewModel.getUserByChat(chat: chattingViewModel.chats[index]) { user in
                self.users[index] = user
                let ref = StorageReferencesManager.shared.getProfileImageReference(userId: user.id)
                ref.downloadURL { url, _ in
                    DispatchQueue.main.async {
                        withAnimation(.easeOut) {
                            imageUrls[index] = url
                            showImage = true
                        }
                    }
                }
            }
        }
    }

}
