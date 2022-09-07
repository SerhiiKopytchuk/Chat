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
    var user: User
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let animationNamespace: Namespace.ID

    @State var showingAlert = false

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true
    @Binding var isFindChat: Bool

    @Binding var isExpandedProfile: Bool
    @Binding var profileImage: WebImage

    let imageSize: CGFloat = 50

    var body: some View {
        HStack(spacing: 20) {

            userImage

            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.title).bold()

                Text("Online")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if isFindChat {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(.white)
                    .cornerRadius(40)
                    .addLightShadow()
                    .onTapGesture {
                        showingAlert.toggle()
                    }
            }
        }
        .padding()
        .onAppear {
            let ref = StorageReferencesManager.shared.getProfileImageReference(userId: user.id)
            ref.downloadURL { url, err in
                if err != nil {
                    self.isFindUserImage = false
                    return
                }
                withAnimation(.easeInOut) {
                    self.profileImage = WebImage(url: url)
                    self.imageUrl = url
                }
            }
        }
        .alert("Do you really want to delete this chat?", isPresented: $showingAlert) {
            Button("Delete", role: .destructive) {
                chattingViewModel.deleteChat()
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.red)
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder var userImage: some View {
        if isFindUserImage {
            VStack {
                if isExpandedProfile {
                    WebImage(url: imageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
                            .opacity(0)
                } else {
                    WebImage(url: imageUrl)
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
}
