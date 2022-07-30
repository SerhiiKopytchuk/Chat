//
//  CreateChannelView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 26.06.2022.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
import UIKit

struct CreateChannelView: View {

    @State var channelImage: UIImage?
    @State var isShowingImagePicker = false
    @State var name: String = ""
    @State var description: String = ""
    @State var searchText: String = ""
    @State var isPrivate = true

    @State var imageUrl = URL(string: "")
    @State var isFindChannelImage = true

    var channelImageSize: CGFloat = 100

    @Namespace var animation

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @ObservedObject var imageViewModel = ImageViewModel()

    @Environment(\.self) var env

    var body: some View {
        ZStack {

            LinearGradient(colors: [
                Color("Gradient1"),
                Color("Gradient2"),
                Color("Gradient3")
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

            VStack {

                HStack(spacing: 15) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "arrow.backward.circle.fill")
                            .toButtonLightStyle(size: 40)
                    }

                    Text("Create channel")
                        .font(.title.bold())
                        .opacity(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()

                ZStack(alignment: .top) {
                    Color("BG")
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                        .offset(x: 0, y: 50)

                    VStack {

                        changeChannelImageView

                        channelNameTextField

                        channelDescriptionTextField

                        channelCustomTabBar
                            .padding()

                        Spacer()

                        createChannelButton
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }

        }
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $channelImage)
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder var changeChannelImageView: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            if self.channelImage != nil {
                ZStack {
                    Image(uiImage: self.channelImage ?? UIImage())
                        .resizable()
                        .scaledToFill()
                        .frame(width: channelImageSize, height: channelImageSize)
                        .cornerRadius(channelImageSize/2)
                        .addLightShadow()
                }
            } else {
                emptyImage
            }

        }
        .frame(width: 100, height: 100)
    }

    @ViewBuilder var emptyImage: some View {
        Image(systemName: "photo.circle.fill")
            .resizable()
            .frame(width: channelImageSize, height: channelImageSize)
            .foregroundColor(.black.opacity(0.70))
            .background(.white)
            .cornerRadius(channelImageSize/2)
            .addLightShadow()
    }

    @ViewBuilder var channelNameTextField: some View {
        Label {
            TextField("Enter name of your channel", text: $name)
        } icon: {
            Image(systemName: "newspaper.fill")
                .opacity(0.7)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white)
        }
        .padding(.top, 25)
        .padding(5)
        .padding(.horizontal)
    }

    @ViewBuilder var channelDescriptionTextField: some View {
        Label {
            TextField("Describe your channel", text: $description)
        } icon: {
            Image(systemName: "doc.plaintext")
                .opacity(0.7)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white)
        }
        .padding(5)
        .padding(.horizontal)
    }

    @ViewBuilder var channelCustomTabBar: some View {
        HStack(spacing: 0) {
            ForEach([ChannelType.publicType, ChannelType.privateType], id: (\.self)) { type in
                Text(type.rawValue.capitalized)
                    .fontWeight(.semibold)
                    .foregroundColor(channelViewModel.channelType == type ? .white : .black)
                    .opacity(channelViewModel.channelType == type ? 1 : 0.7)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background {
                        if channelViewModel.channelType == type {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    LinearGradient(colors: [
                                        Color("Gradient1"),
                                        Color("Gradient2"),
                                        Color("Gradient3")
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .matchedGeometryEffect(id: "TYPE", in: animation)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            channelViewModel.channelType = type
                        }
                    }
            }
        }
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white)
        }
    }

    @ViewBuilder var createChannelButton: some View {
        Button {
            name = name.trim()
            description = description.trim()

            if !name.isValidateLengthOfName() {
                return
            }

            channelViewModel.currentUser = viewModel.currentUser
            channelViewModel.owner = viewModel.currentUser
            channelViewModel.createChannel( name: self.name,
                                            description: self.description) { channel in

                    imageViewModel.saveImage(image: self.channelImage ?? UIImage(),
                                             imageName: channel.id ?? "some Id")

                channelViewModel.getChannels(fromUpdate: true)
                env.dismiss()
            }
        } label: {
            Text("Create")
                .toButtonGradientStyle()
        }
        .opacity(name.isValidateLengthOfName() ? 1 : 0.6)
        .disabled(name.isValidateLengthOfName() ? false : true)

    }
}

struct CreateChannelView_Previews: PreviewProvider {
    static var previews: some View {
        CreateChannelView()
            .environmentObject(ChannelViewModel())
            .environmentObject(UserViewModel())
    }
}
