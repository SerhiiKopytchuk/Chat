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

    let animationNamespace: Namespace.ID
    @Binding var isExpandedProfile: Bool
    @Binding var isExpandedDetails: Bool
    @Binding var profileImage: WebImage

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
                            .matchedGeometryEffect(id: "channelPhoto", in: animationNamespace)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpandedProfile.toggle()
                    }
                }
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
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpandedDetails.toggle()
                }
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
                    self.profileImage = WebImage(url: url)
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
