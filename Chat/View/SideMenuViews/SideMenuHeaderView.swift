//
//  SideMenuHeaderView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import SDWebImageSwiftUI
struct SideMenuHeaderView: View {
    // MARK: - vars
    @Binding var isShowingSideMenu: Bool
    @EnvironmentObject var userViewModel: UserViewModel

    // MARK: image properties
    @State private var myImageUrl = URL(string: "")
    @State private var isFindUserImage = true
    private let imageSize: CGFloat = 65

    // MARK: - body
    var body: some View {

        ZStack(alignment: .topTrailing) {
            closeSideMenuButton

            VStack(alignment: .leading) {

                userImage

                Text(userViewModel.currentUser.name)
                    .font(.system(size: 24, weight: .semibold))

                Text(userViewModel.currentUser.gmail)
                    .font(.system(size: 14 ))
                    .padding(.bottom, 24)

                // MARK: chats and channels label
                HStack {
                    HStack {
                        Text("\(userViewModel.currentUser.chats.count)").bold()
                        Text(userViewModel.currentUser.chats.count == 1 ? "Chat" : "Chats")
                    }
                    HStack {
                        Text("\(userViewModel.currentUser.channels.count)").bold()
                        Text(userViewModel.currentUser.channels.count == 1 ? "Channel" : "Channels")
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }

    // MARK: - viewBuilders
    @ViewBuilder private var userImage: some View {
        if isFindUserImage {
            WebImage(url: myImageUrl)
                .resizable()
                .scaledToFill()
                .clipped()
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
                .padding(.bottom, 16)
                .addLightShadow()
                .onAppear {
                    imageStartSetup()
                }
                .accessibilityValue("notEmptyImage")
        } else {
            EmptyImageWithCharacterView(text: userViewModel.currentUser.name,
                                        colour: userViewModel.currentUser.colour,
                                        size: imageSize)
                .padding(.bottom, 16)
        }
    }

    @ViewBuilder private var closeSideMenuButton: some View {
        Button {
            withAnimation(.spring()) {
                isShowingSideMenu.toggle()
            }
        } label: {
            Image(systemName: "xmark")
                .frame(width: 32, height: 32)
                .padding()
        }
    }

    // MARK: - functions
    private func imageStartSetup() {
        let ref = StorageReferencesManager.shared.getProfileImageReference(userId: userViewModel.currentUser.id)
        ref.downloadURL { url, err in
            if err != nil {
                self.isFindUserImage = false
                return
            }
            withAnimation(.easeInOut) {
                self.myImageUrl = url
            }
        }
    }
}

struct SideMenuHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuHeaderView(isShowingSideMenu: .constant(true))
            .environmentObject(UserViewModel())
    }
}
