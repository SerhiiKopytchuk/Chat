//
//  Data + extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 09.04.2023.
//

import Foundation
import UIKit

extension Data {
    var image: UIImage? {
        if let image = UIImage(data: self) {
            return image
        } else {
            return nil
        }
    }
}
