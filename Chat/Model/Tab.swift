//
//  Tab.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.05.2022.
//

import Foundation

struct Tab: Identifiable, Hashable {
    let id = UUID().uuidString
    let name: String
    let index: Int

    var width: CGFloat = 0
    var minX: CGFloat = 0
}
