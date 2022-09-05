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

}
