//
//  SizePreferenceKey.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.01.2023.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
