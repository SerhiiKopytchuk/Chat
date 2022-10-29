//
//  Array + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.10.2022.
//

import Foundation

extension Array where Element == Message {
    func isContains(message: Message) -> Bool {
        for element in self where
        element.text == message.text &&
        element.senderId == message.senderId &&
        element.timestamp.timeIntervalSince(message.timestamp) < 1 {
            return true
        }
        return false
    }
}
