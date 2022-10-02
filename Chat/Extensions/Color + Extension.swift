//
//  Color + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 04.09.2022.
//

import SwiftUI

extension Color {
    static let underline = LinearGradient(gradient:
                                            Gradient(colors: [.black.opacity(0),
                                                .black,
                                                .black.opacity(0)]),
                                          startPoint: .leading, endPoint: .trailing)

    static let segmentControlBackground = LinearGradient(gradient:
                                                    Gradient(colors: [Color("Background 1").opacity(0.1),
                                                                      Color("Background 2").opacity(0.1)]),
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing)
    static let background = Color("BG")

    static let secondPrimary = Color("secondPrimary")
    static let secondPrimaryReversed = Color("secondPrimaryReversed")

    static let textFieldColor = Color("TextFieldColor")

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
