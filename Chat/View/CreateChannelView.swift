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
    // MARK: - vars
    @State private var channelImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var searchText: String = ""
    @State private var isPrivate = true

    // MARK: image properties
    @State private var imageUrl = URL(string: "")
    @State private var isFindChannelImage = true
    private let channelImageSize: CGFloat = 100

    @State private var isShowAlert = false

    @Namespace var animation

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @ObservedObject var imageViewModel = ImageViewModel()

    @Environment(\.self) var env

    // MARK: - body
    var body: some View {
        ZStack {

            Color.mainGradient
                .ignoresSafeArea()

            VStack {

                HeaderWithBackButton(environment: _env, text: "Create channel")
                    .padding()

                ZStack(alignment: .top) {

                    Color.background
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

            customAlert
        }
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $channelImage)
        }
        .navigationBarHidden(true)
    }

    // MARK: - viewBuilders
    @ViewBuilder private var changeChannelImageView: some View {
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
        .frame(width: channelImageSize, height: channelImageSize)
    }

    @ViewBuilder private var emptyImage: some View {
        Image(systemName: "photo.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .frame(width: channelImageSize, height: channelImageSize)
            .foregroundColor(.secondPrimary)
            .background(Color.secondPrimaryReversed)
            .cornerRadius(channelImageSize/2)
            .addLightShadow()
    }

    @ViewBuilder private var channelNameTextField: some View {
        Label {
            TextField("Enter name of your channel", text: $name)
                .foregroundColor(.primary)
        } icon: {
            Image(systemName: "newspaper.fill")
                .foregroundColor(.primary)
                .opacity(0.7)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.secondPrimary)
        }
        .padding(.top, 25)
        .padding(5)
        .padding(.horizontal)
    }

    @ViewBuilder private var channelDescriptionTextField: some View {
        Label {
            TextField("Describe your channel", text: $description)
                .foregroundColor(.primary)
        } icon: {
            Image(systemName: "doc.plaintext")
                .foregroundColor(.primary)
                .opacity(0.7)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.secondPrimary)
        }
        .padding(5)
        .padding(.horizontal)
    }

    @ViewBuilder private var channelCustomTabBar: some View {
        HStack(spacing: 0) {
            ForEach([ChannelType.publicType, ChannelType.privateType], id: (\.self)) { type in
                Text(type.rawValue.capitalized)
                    .fontWeight(.semibold)
                    .foregroundColor(channelViewModel.channelType == type ? .white : .primary)
                    .opacity(channelViewModel.channelType == type ? 1 : 0.7)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background {
                        if channelViewModel.channelType == type {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    Color.mainGradient
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
                .fill(Color.secondPrimary)
        }
    }

    @ViewBuilder private var createChannelButton: some View {
        Button {
            name = name.trim()
            description = description.trim()

            if !name.isValidateLengthOfName() {
                withAnimation {
                    isShowAlert = true
                }
                return
            }

            channelViewModel.currentUser = viewModel.currentUser
            channelViewModel.owner = viewModel.currentUser
            channelViewModel.createChannel( name: self.name,
                                            description: self.description) { channel in

                imageViewModel.saveChannelImage(image: self.channelImage ?? UIImage(),
                                                channelId: channel.id ?? "some Id") { _ in

                }
                if channelImage != nil {
                    channelViewModel.saveImageLocally(image: self.channelImage ?? UIImage(),
                                                      imageName: channel.id ?? "someId")
                }
                env.dismiss()
            }
        } label: {
            Text("Create")
                .toButtonGradientStyle()
        }
        .opacity(name.isValidateLengthOfName() ? 1 : 0.6)
    }

    @ViewBuilder private var customAlert: some View {
        if isShowAlert {
            GeometryReader { geometry in
                CustomAlert(show: $isShowAlert, text: name.count > 3 ?
                                "Name should be shorter than 35 symbols" :
                                "Name should be longer than 3 symbols")

                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                .frame(maxWidth: geometry.frame(in: .local).width - 20)
            }
            .background(Color.white.opacity(0.65))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct CreateChannelView_Previews: PreviewProvider {
    static var previews: some View {
        CreateChannelView()
            .environmentObject(ChannelViewModel())
            .environmentObject(UserViewModel())
    }
}
