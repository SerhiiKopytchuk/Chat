//
//  ImagePickerViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 21.12.2022.
//

import SwiftUI
import PhotosUI

class ImagePickerViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var fetchedImages: [ImageAsset] = []
    @Published var selectedImages: [ImageAsset] = []

    @Published var haveAccessToLibrary: Bool = false

    override init() {
        super.init()

        PHPhotoLibrary.shared().register(self)

        let authStatus = PHPhotoLibrary.authorizationStatus()
        haveAccessToLibrary = authStatus == .authorized || authStatus == .limited

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

    func photoLibraryDidChange(_ changeInstance: PHChange) {
            updateStatus()
    }

    private func updateStatus() {
        DispatchQueue.main.async {
            self.haveAccessToLibrary = PHPhotoLibrary.authorizationStatus() == .authorized ||
                                       PHPhotoLibrary.authorizationStatus() == .limited
            if self.haveAccessToLibrary {
                self.fetchImages()
            }
        }
    }
}
