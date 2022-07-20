//
//  removeUsersFromChannelListRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.07.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct RemoveUsersFromChannelListRow: View {
    var user: String
    var userGmail: String
    var id: String

    @EnvironmentObject var channelViewModel: ChannelViewModel

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
            Image(systemName: "minus")
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundColor(.orange)
                .padding()
                .onTapGesture {
                    channelViewModel.removeChannelFromSubscriptionsWithCertainUser(id: self.id)
                    withAnimation {
                        channelViewModel.removeUserFromSubscribersList(id: self.id)
                    }
                    channelViewModel.getChannelSubscribers()
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

        }
    }

}

struct RemoveUsersFromChannelListRow_Previews: PreviewProvider {
    static var previews: some View {
        RemoveUsersFromChannelListRow(user: "Koch",
                                userGmail: "koch@gmail.com",
                                id: "someId"
        )
    }
}
