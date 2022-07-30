//
//  AddUserCreateChannelRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 27.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct AddUserToChannelRow: View {
    var user: String
    var userGmail: String
    var id: String
    @Binding var subscribersId: [String]
    @State var isAddedToChannel = false

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    var body: some View {
        HStack {
            if isFindUserImage {
                WebImage(url: imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                    .addLightShadow()
                    .padding()
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .addLightShadow()
                    .padding()
            }
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
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white)
        }
        .onAppear {
            let ref = Storage.storage().reference(withPath: self.id )
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

    @ViewBuilder var addOrRemoveUserChannel: some View {
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
}

struct AddUserCreateChannelRow_Previews: PreviewProvider {
    static var previews: some View {
        AddUserToChannelRow(user: "Koch",
                                userGmail: "koch@gmail.com",
                                id: "someId",
                                subscribersId: .constant([]))
    }
}
