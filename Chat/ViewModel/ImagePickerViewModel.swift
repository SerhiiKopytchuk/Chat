//
//  ImagePickerViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 21.12.2022.
//

import SwiftUI
import PhotosUI

class ImagePickerViewModel: ObservableObject {
    @Published var fetchedImages: [ImageAsset] = []
    @Published var selectedImages: [ImageAsset] = []

    init() {
        fetchImages()
    }

    func fetchImages() {
        let options = PHFetchOptions()

        options.includeHiddenAssets = false
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        PHAsset.fetchAssets(with: .image, options: options).enumerateObjects { asset, _, _ in
            let imageAsset = ImageAsset(asset: asset)
            self.fetchedImages.append(imageAsset)
        }
    }

}
