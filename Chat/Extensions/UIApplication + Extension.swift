//
//  UIApplication + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 25.08.2022.
//

import SwiftUI

extension UIApplication {
    /// hide keyboard
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
