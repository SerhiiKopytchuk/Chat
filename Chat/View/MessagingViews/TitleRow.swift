//
//  TitleRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct TitleRow: View {
    var user: User
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let animationNamespace: Namespace.ID

    @State var showingAlert = false

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    @Binding var isExpandedProfile: Bool
    @Binding var profileImage: WebImage

    var body: some View {
        HStack(spacing: 20) {
            if isFindUserImage {
                VStack {
                    if isExpandedProfile {
                        WebImage(url: imageUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .cornerRadius(50)
                                .opacity(0)
                    } else {
                        WebImage(url: imageUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .cornerRadius(50)
                                .matchedGeometryEffect(id: "profilePhoto", in: animationNamespace)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpandedProfile.toggle()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
            }

            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.title).bold()

                Text("Online")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "xmark")
                .foregroundColor(.gray)
                .padding(10)
                .background(.white)
                .cornerRadius(40 )
                .onTapGesture {
                    showingAlert.toggle()
                }
        }
        .padding()
        .onAppear {
            let ref = Storage.storage().reference(withPath: user.id )
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
                chattingViewModel.getChats(fromUpdate: true)
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.red)
            Button("Cancel", role: .cancel) {}
        }
    }
}
