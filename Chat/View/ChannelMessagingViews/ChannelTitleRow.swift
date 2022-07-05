//
//  ChannelTitleRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct ChannelTitleRow: View {
    var channel: Channel

    @EnvironmentObject var channelViewModel: ChannelViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var showingAlertOwner = false
    @State var showingAlertSubscriber = false

    @State var isOwner: Bool

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    var body: some View {
        HStack(spacing: 20) {
            if isFindUserImage {
                WebImage(url: imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(50)
            } else {
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
            }

            VStack(alignment: .leading) {
                Text(channel.name)
                    .font(.title).bold()

                Text(channel.description)
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
                    if isOwner {
                        showingAlertOwner.toggle()
                    } else {
                        showingAlertSubscriber.toggle()
                    }
                }
        }
        .padding()
        .onAppear {
            let ref = Storage.storage().reference(withPath: channel.id ?? "someId" )
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
        .alert("Do you really want to delete this channel?", isPresented: $showingAlertOwner) {
            Button("Delete", role: .destructive) {
                channelViewModel.deleteChannel()
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.red)
            Button("Cancel", role: .cancel) {}
        }
        .alert("Do you really want to unsubscribe from this channel?", isPresented: $showingAlertSubscriber) {
            Button("Unsubscribe", role: .destructive) {
                channelViewModel.removeChannelFromSubscriptions(id: self.channelViewModel.currentUser.id)
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.red)
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct ChannelTitleRow_Previews: PreviewProvider {
    static var previews: some View {
        ChannelTitleRow(channel: Channel(id: "some id",
                                         name: "name",
                                         description: "description",
                                         ownerId: "owner id",
                                         subscribersId: [],
                                         messages: []), isOwner: true)
    }
}
