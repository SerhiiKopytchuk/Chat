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
}
