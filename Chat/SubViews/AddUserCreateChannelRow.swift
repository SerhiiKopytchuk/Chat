//
//  AddUserCreateChannelRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 27.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct AddUserCreateChannelRow: View {
    var user: String
    var userGmail: String
    var id: String
    @EnvironmentObject var channelViewModel: ChannelViewModel
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.black, lineWidth: 1)
                            .shadow(radius: 5)
                    )
                    .padding()
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .padding()
            }
            VStack(alignment: .leading) {
                Text(user)
                    .font(.title)
                Text(userGmail)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            addOrRemoveUserChannel
                .padding()
                .onTapGesture {
                    if channelViewModel.subscribers.contains(id) {

                        withAnimation {
                            isAddedToChannel = false
                        }
                        if let index = channelViewModel.subscribers.firstIndex(of: id) {
                            channelViewModel.subscribers.remove(at: index)
                        }

                    } else {
                        isAddedToChannel = true
                        withAnimation {
                            channelViewModel.subscribers.append(id)
                        }
                    }
                }
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

            if channelViewModel.subscribers.contains(id) {
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
                        .foregroundColor(.orange)
                }
            } else {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(.orange)
            }
    }
}

struct AddUserCreateChannelRow_Previews: PreviewProvider {
    static var previews: some View {
        AddUserCreateChannelRow(user: "Koch",
                                userGmail: "koch@gmail.com",
                                id: "someId")
    }
}
