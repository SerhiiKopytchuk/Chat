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
import PhotosUI

struct CreateChannelView: View {
    // MARK: - vars
    @State private var channelImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var name: String = ""
    @State private var description: String = ""

    private let channelImageSize: CGFloat = 100

    @State private var alertText: String?

    @Namespace var animation

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @ObservedObject var imageViewModel = ImageViewModel()

    @Environment(\.self) var env

    // MARK: - body
    var body: some View {

        VStack {
            HeaderWithBackButton(environment: _env, text: "Create channel")

            changeChannelImageView

            TextFieldWithBorders(iconName: "newspaper.fill",
                                 placeholderText: "Enter name of your channel",
                                 text: $name,
                                 color: Color.secondPrimaryReversed)
            .padding([.top, .horizontal])

            TextFieldWithBorders(iconName: "doc.plaintext",
                                 placeholderText: "Describe your channel",
                                 text: $description,
                                 color: Color.secondPrimaryReversed)
            .padding([.top, .horizontal])

            channelCustomTabBar
                .padding()

            Spacer()

            createChannelButton
                .padding()

        }
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .overlay {
            customAlert
        }
        .sheet(isPresented: $isShowingImagePicker, content: {
            CustomImagePicker(onSelect: { assets in
                parseImages(with: assets)
            },
                              isPresented: $isShowingImagePicker,
                              maxAmountOfImages: 1,
                              imagePickerModel: ImagePickerViewModel())
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        })
        .navigationBarHidden(true)
        .addRightGestureRecognizer {
            env.dismiss()
        }

    }

    // MARK: - viewBuilders
    @ViewBuilder private var changeChannelImageView: some View {
        Button {
            UIApplication.shared.endEditing()
            isShowingImagePicker.toggle()
        } label: {
            ZStack {

                Circle()
                    .stroke(Color.secondPrimaryReversed, lineWidth: 3)
                    .frame(width: channelImageSize + 1, height: channelImageSize + 1)

                if self.channelImage != nil {
                        Image(uiImage: self.channelImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: channelImageSize, height: channelImageSize)
                            .cornerRadius(channelImageSize/2)
                            .addLightShadow()
                } else {
                    emptyImage
                }

                Image(systemName: "camera")
                    .imageScale(.small)
                    .background {
                        Circle()
                            .fill(Color.secondPrimaryReversed)
                            .frame(width: 25, height: 25)
                    }
                    .foregroundColor(Color.secondPrimary)
                    .offset(x: channelImageSize/2 - 15, y: channelImageSize/2 - 15)
            }

        }
        .frame(width: channelImageSize, height: channelImageSize)
        .padding(.vertical)
        .padding(.top)
    }

    @ViewBuilder private var emptyImage: some View {
        Image(systemName: "photo.circle.fill")
            .resizable()
            .frame(width: channelImageSize, height: channelImageSize)
            .foregroundColor(.secondPrimaryReversed)
            .cornerRadius(channelImageSize/2)
            .addLightShadow()
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
                    alertText = name.count > 3 ?
                    "Name should be shorter than 35 symbols" :
                    "Name should be longer than 3 symbols"
                }
                return
            }

            channelViewModel.owner = viewModel.currentUser
            channelViewModel.createChannel( name: self.name,
                                            description: self.description) { channel in

                if let channelImageUnwrapped = channelImage {
                    imageViewModel.saveChannelImage(image: channelImageUnwrapped,
                                                    channelId: channel.id ?? "some Id") { _ in
                    }

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
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private var customAlert: some View {
        if alertText != nil {
            CustomAlert(text: $alertText, type: .failure)
        }
    }

    // MARK: - functions

    func parseImages(with assets: [PHAsset]) {
        guard !assets.isEmpty else { return }
        isShowingImagePicker = false

        let manager = PHCachingImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true

        DispatchQueue.global(qos: .userInteractive).async {
            manager.requestImage(for: assets.first ?? PHAsset(),
                                 targetSize: .init(),
                                 contentMode: .default,
                                 options: options) { image, _ in
                guard let image else { return }
                DispatchQueue.main.async {
                    self.channelImage = image
                }
            }
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
