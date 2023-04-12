//
//  UIImage.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 09.04.2023.
//

import Foundation
import UIKit

extension UIImage {
    var data: Data? {
        if let data = self.jpegData(compressionQuality: 1.0) {
            return data
        } else {
            return nil
        }
    }
}
