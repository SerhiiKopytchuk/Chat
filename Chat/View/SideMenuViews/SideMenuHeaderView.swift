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
    private let imageSize: CGFloat = 65

    // MARK: - body
    var body: some View {

            VStack(alignment: .leading) {

                userImage

                Text(userViewModel.currentUser.name)
                    .font(.system(size: 24, weight: .semibold))

                Text(userViewModel.currentUser.gmail)
                    .font(.system(size: 14 ))
            }
            .padding()
    }

    // MARK: - viewBuilders
    @ViewBuilder private var userImage: some View {
            WebImage(url: myImageUrl)
                .placeholder(content: {
                    EmptyImageWithCharacterView(text: userViewModel.currentUser.name,
                                                colour: userViewModel.currentUser.colour,
                                                size: imageSize)
                })
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
    }

    // MARK: - functions
    private func imageStartSetup() {
        let ref = StorageReferencesManager.shared.getProfileImageReference(userId: userViewModel.currentUser.id)
        DispatchQueue.global(qos: .utility).async {
            ref.downloadURL { url, _ in
                DispatchQueue.main.async {
                    withAnimation(.easeOut) {
                        self.myImageUrl = url
                    }
                }
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
