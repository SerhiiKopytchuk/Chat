//
//  offsetKey.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 11.01.2023.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
