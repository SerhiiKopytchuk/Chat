//
//  Color + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 04.09.2022.
//

import SwiftUI

extension Color {
    static let background = Color("BG")

    static let secondPrimary = Color("secondPrimary")
    static let secondPrimaryReversed = Color("secondPrimaryReversed")

    static let mainGradient = LinearGradient(gradient:
                                                Gradient(colors: [
                                                   Color("Gradient1"),
                                                   Color("Gradient2"),
                                                   Color("Gradient3"),
                                                   Color("Gradient4"),
                                                   Color("Gradient5"),
                                                   Color("Gradient6")
                                                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
}
