//
//  BoundsPreference.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 07.08.2022.
//

import SwiftUI

struct BoundsPreference: PreferenceKey {

    static var defaultValue: [String: Anchor<CGRect> ] = [:]

    static func reduce(value: inout [ String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) {$1}
    }
}
