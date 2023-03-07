//
//  EditChannelView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 22.07.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
import PhotosUI

struct EditChannelView: View {

    // MARK: - vars

    @State var channelName: String
    @State var channelDescription: String
    @State var channelColor: String

    // MARK: image properties
    @State var channelImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var imageUrl = URL(string: "")
    @State private var isFindUserImage = true
    private let imageSize: CGFloat = 50

    @State private var alertText: String?

    @EnvironmentObject private var editChannelViewModel: EditChannelViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel
    @EnvironmentObject private var imageViewModel: ImageViewModel

    @Environment(\.self) var presentationMode

    // MARK: - body
    var body: some View {
        VStack(spacing: 5) {
            header
            HStack {
                imageButton

                TextField("Enter channel name", text: $channelName)
                    .autocorrectionDisabled()
                    .foregroundColor(.primary)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 15)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.secondPrimary)
                    }
                    .padding(.trailing)
                    .padding(.vertical)
            }

            TextField("Type channel description", text: $channelDescription)
                .foregroundColor(.primary)
                .padding(.vertical, 20)
                .padding(.horizontal, 15)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.secondPrimary)
                }
                .padding(.horizontal)

            Spacer()
        }
        .navigationBarHidden(true)
        .addRightGestureRecognizer {
            presentationMode.dismiss()
        }
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .onChange(of: channelImage ?? UIImage(), perform: { newImage in
            imageViewModel.saveChannelImage(image: newImage,
                                            channelId: channelViewModel.currentChannel.id ?? "some id") { _ in }
        })
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
        .overlay {
            customAlert
        }
    }

    // MARK: - ViewBuilders
    @ViewBuilder private var header: some View {
        HStack(spacing: 15) {
            Button {
                presentationMode.dismiss()
            } label: {
                Image(systemName: "arrow.backward.circle.fill")
                    .toButtonLightStyle(size: 40)
            }

            Text("Edit channel")
                .lineLimit(1)
                .font(.title.bold())
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                channelName = channelName.trim()
                channelDescription = channelDescription.trim()
                if channelName.isValidateLengthOfName() {
                    editChannelViewModel.updateChannelInfo(name: channelName, description: channelDescription)

                    channelViewModel.currentChannel.name = channelName
                    channelViewModel.currentChannel.description = channelDescription
                    channelViewModel.getChannels(fromUpdate: true)
                    presentationMode.dismiss()
                } else {
                    alertText = channelName.count > 3 ?
                    "Name should be shorter than 35 symbols" :
                    "Name should be longer than 3 symbols"
                }
            } label: {
                Image(systemName: "checkmark")
                    .toButtonLightStyle(size: 40)
            }
            .frame(alignment: .trailing)
        }
        .padding(.horizontal)
    }

    @ViewBuilder private var imageButton: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            if isFindUserImage {
                if self.channelImage != nil {
                    ZStack {
                        Image(uiImage: self.channelImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
                    }
                } else {
                    ZStack {
                        WebImage(url: imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
                    }
                }
            } else {
                if self.channelImage != nil {
                    Image(uiImage: self.channelImage ?? UIImage())
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(imageSize/2)
                        .addLightShadow()
                } else {
                    EmptyImageWithCharacterView(text: channelName, colour: channelColor, size: imageSize)
                        .accessibilityValue("emptyImage")
                }
            }
        }
        .padding()
        .onAppear {
            imageSetup()
        }
    }

    @ViewBuilder private var customAlert: some View {
        if alertText != nil {
            CustomAlert(text: $alertText, type: .failure)
        }
    }

    // MARK: - functions
    private func imageSetup() {
        let ref = StorageReferencesManager.shared
            .getChannelImageReference(channelId: channelViewModel.currentChannel.id ?? "some id")
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

struct EditChannelView_Previews: PreviewProvider {
    static var previews: some View {
        EditChannelView(channelName: "Channel", channelDescription: "Description", channelColor: "Red")
            .environmentObject(ChannelViewModel())
            .environmentObject(EditChannelViewModel())
            .environmentObject(ImageViewModel())
    }
}
