//
//  TitleRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct ConversationTitleRow: View {
    // MARK: - variables
    var user: User
    @EnvironmentObject private var chattingViewModel: ChattingViewModel
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    let animationNamespace: Namespace.ID

    @State private var showingAlert = false

    // MARK: image properties
    @State private var isFindUserImage = true
    @Binding var isFindChat: Bool

    @Binding var isExpandedProfile: Bool
    @Binding var profileImageURL: URL?
    private let imageSize: CGFloat = 50

    // MARK: - Body
    var body: some View {
        HStack(spacing: 20) {

            userImage

            // MARK: userName
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.title).bold()

                Text("Online")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: remove chat button
            if isFindChat {
                Image(systemName: "xmark")
                    .foregroundColor(.primary.opacity(0.6))
                    .padding(10)
                    .background(Color.secondPrimary)
                    .addLightShadow()
                    .onTapGesture {
                        showingAlert.toggle()
                    }
                    .clipShape(Circle())
            }

        }
        .padding()
        .onAppear {
            imageStartSetup()
        }
        .alert("Do you really want to delete this chat?", isPresented: $showingAlert) {
            Button("Delete", role: .destructive) {
                chattingViewModel.deleteChat()
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.red)
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - viewBuilders
    @ViewBuilder private var userImage: some View {
        if isFindUserImage {
            VStack {
                if isExpandedProfile {
                    WebImage(url: profileImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
                            .opacity(0)
                } else {
                    WebImage(url: profileImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
                            .matchedGeometryEffect(id: "profilePhoto", in: animationNamespace)
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpandedProfile.toggle()
                }
            }
        } else {
            if let first = user.name.first {
                Text(String(first.uppercased()))
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .frame(width: imageSize, height: imageSize)
                    .background {
                        Circle()
                            .fill(Color(user.colour))
                    }
                    .addLightShadow()
            }
        }

    }

    // MARK: - functions
    private func imageStartSetup() {
        let ref = StorageReferencesManager.shared.getProfileImageReference(userId: user.id)
        ref.downloadURL { url, err in
            if err != nil {
                self.isFindUserImage = false
                return
            }
            withAnimation(.easeInOut) {
                    self.profileImageURL = url
            }
        }
    }
}
