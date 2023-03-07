//
//  CustomImagePicker.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 21.12.2022.
//

import SwiftUI
import PhotosUI

struct CustomImagePicker: View {

    // MARK: - Variables

    var onSelect: ([PHAsset]) -> Void
    @Binding var isPresented: Bool

    let maxAmountOfImages: Int

    // MARK: - EnvironmentObjects

    @StateObject var imagePickerModel: ImagePickerViewModel

    // MARK: - body
    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        VStack(spacing: 0) {

            headerView

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)) {
                    ForEach($imagePickerModel.fetchedImages) { $imageAsset in
                        gridBuilder(imageAsset: imageAsset)
                            .onAppear {
                                if imageAsset.thumbnail == nil {
                                    let manager = PHCachingImageManager.default()
                                    manager.requestImage(for: imageAsset.asset,
                                                         targetSize: CGSize(width: 100, height: 100),
                                                         contentMode: .aspectFill, options: nil) { image, _ in
                                        imageAsset.thumbnail = image
                                    }
                                }
                            }
                    }
                }
                .padding()
            }
            .frame(maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                if !imagePickerModel.selectedImages.isEmpty {
                    sendButton
                }
            }
        }
        .onChange(of: isPresented, perform: { _ in
            imagePickerModel.selectedImages = []
        })
        .onAppear(perform: {
            imagePickerModel.selectedImages = []
        })
        .frame(maxWidth: (deviceSize.width - 40) > 350 ? 350 : (deviceSize.width - 40))
    }

    // MARK: - ViewBuilders

    @ViewBuilder private var headerView: some View {
        HStack {
            Text("Select Images")
                .font(.callout.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 10)

    }

    @ViewBuilder private func gridBuilder(imageAsset: ImageAsset) -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                if let thumbnail = imageAsset.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    ProgressView()
                        .frame(width: size.width, height: size.height, alignment: .center)
                }

                if maxAmountOfImages > 1 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.black.opacity(0.1))

                        Circle()
                            .fill(.white.opacity(0.25))

                        Circle()
                            .stroke(.white, lineWidth: 1)

                        if let index = imagePickerModel.selectedImages.firstIndex(where: { asset in
                            asset.id == imageAsset.id
                        }) {
                            Circle()
                                .fill(.blue)

                            if maxAmountOfImages > 1 {
                                Text("\(imagePickerModel.selectedImages[index].assetIndex + 1)")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(width: 20, height: 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(5)
                }
            }
            .clipped()
            .onTapGesture {
                imageTap(imageAsset: imageAsset)
            }
        }
        .frame(height: 70)
    }

    @ViewBuilder private var sendButton: some View {
        Button {
            sendButtonTapped()
        } label: {
            Text(maxAmountOfImages > 1 ?
                 "Send \(imagePickerModel.selectedImages.count) " +
                 (imagePickerModel.selectedImages.count == 1 ? "image" : "images") :
                    "Choose"
            )
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(.blue)
            }
        }
        .disabled(imagePickerModel.selectedImages.isEmpty)
        .opacity(imagePickerModel.selectedImages.isEmpty ? 0.6 : 1)
        .padding(.vertical)
    }

    // MARK: - functions

    private func imageTap(imageAsset: ImageAsset) {
        withAnimation(.easeInOut) {
            if maxAmountOfImages == 1 {
                var newAsset = imageAsset
                newAsset.assetIndex = imagePickerModel.selectedImages.count
                imagePickerModel.selectedImages = [newAsset]
                sendButtonTapped()
            } else {
                if let index = imagePickerModel.selectedImages.firstIndex(where: { asset in
                    asset.id == imageAsset.id
                }) {
                    imagePickerModel.selectedImages.remove(at: index)
                    imagePickerModel.selectedImages.enumerated().forEach { item in
                        imagePickerModel.selectedImages[item.offset].assetIndex = item.offset
                    }
                } else {
                    if imagePickerModel.selectedImages.count < maxAmountOfImages {
                        var newAsset = imageAsset
                        newAsset.assetIndex = imagePickerModel.selectedImages.count
                        imagePickerModel.selectedImages.append(newAsset)
                    }
                }
            }
        }
    }

    private func sendButtonTapped() {
        let imageAssets = imagePickerModel.selectedImages.compactMap { imageAsset -> PHAsset? in
            return imageAsset.asset
        }
        onSelect(imageAssets)
        imagePickerModel.selectedImages = []
    }
}

#if DEBUG
struct CustomImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomImagePicker(onSelect: { _ in

        }, isPresented: .constant(true),
                          maxAmountOfImages: 3,
                          imagePickerModel: ImagePickerViewModel())
    }
}
#endif
