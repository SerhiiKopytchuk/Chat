//
//  AddUserCreateChannelRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 27.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct AddUserToChannelListRow: View {
    // MARK: - vars
    var user: String
    var userGmail: String
    var id: String
    var colour: String
    @Binding var subscribersId: [String]

    @State private var isAddedToChannel = false

    // MARK: image properties
    @State private var imageUrl = URL(string: "")
    @State private var isFindUserImage = true
    private let imageSize: CGFloat = 40

    // MARK: - body
    var body: some View {
        HStack {

            userImage

            // MARK: userName and userGmail
            VStack(alignment: .leading) {
                Text(user)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(userGmail)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()

            addOrRemoveUserChannel
                .padding()
                .onTapGesture {
                    addOrRemoveUserLogic()
                }
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white)
        }
        .onAppear {

        }
    }

    // MARK: - viewBuilders

    @ViewBuilder private var userImage: some View {
        if isFindUserImage {
            WebImage(url: imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(imageSize/2)
                .addLightShadow()
                .padding()
        } else {
            EmptyImageWithCharacterView(text: user, colour: colour, size: imageSize)
                .padding()
        }
    }

    @ViewBuilder private var addOrRemoveUserChannel: some View {
            if isAddedToChannel {
                HStack {
                    Image(systemName: "minus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(.blue.opacity(0.7))
                        .addLightShadow()
                }
            } else {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(.blue.opacity(0.7))
                    .addLightShadow()
            }
    }

    // MARK: - functions
    private func addOrRemoveUserLogic() {
        if subscribersId.contains(id) {
            withAnimation {
                isAddedToChannel = false
            }
            if let index = subscribersId.firstIndex(of: id) {
                subscribersId.remove(at: index)
            }
        } else {
            isAddedToChannel = true
            withAnimation {
                subscribersId.append(id)
            }
        }
    }

    private func imageStartSetup() {
        let ref = StorageReferencesManager.shared.getProfileImageReference(userId: self.id)
        ref.downloadURL { url, err in
            if err != nil {
                self.isFindUserImage = false
                return
            }
            withAnimation(.easeInOut) {
                self.imageUrl = url
            }
        }

        if subscribersId.contains(id) {
            isAddedToChannel = true
        } else {
            isAddedToChannel = false
        }
    }
}

struct AddUserCreateChannelRow_Previews: PreviewProvider {
    static var previews: some View {
        AddUserToChannelListRow(user: "Koch",
                                userGmail: "koch@gmail.com",
                                id: "someId",
                                colour: "Red",
                                subscribersId: .constant([]))
    }
}
