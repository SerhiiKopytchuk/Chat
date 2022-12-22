//
//  ImageAsset.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 21.12.2022.
//

import SwiftUI
import PhotosUI

struct ImageAsset: Identifiable {
    var id = UUID().uuidString
    var asset: PHAsset
    var thumbnail: UIImage?
    var assetIndex: Int = -1
}
