//
//  String + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 22.07.2022.
//

import Foundation

extension String {

    func trim() -> String {

        if self.trimmingCharacters(in: .whitespaces).isEmpty {
            return ""
        }

        return self.trimmingCharacters(in: .whitespaces)
    }

    func trimToMessage() -> String {

        var trimmedValue = self

        while trimmedValue != trimmedValue.trimmingCharacters(in: .newlines) ||
                trimmedValue != trimmedValue.trimmingCharacters(in: .whitespaces) {

            trimmedValue = trimmedValue.trimmingCharacters(in: .whitespaces)
            trimmedValue = trimmedValue.trimmingCharacters(in: .newlines)

        }

        return trimmedValue
    }

    func isValidateLengthOfName() -> Bool {
        if self.count > 3 && self.count < 35 {
            return true
        }
        return false
    }

    static func getRandomColorFromAssets() -> String {
        let colorsArray = [
            "Green",
            "Purple",
            "Yellow",
            "Red"
        ]
        let randomIndex = Int.random(in: 0...colorsArray.count - 1)

        return colorsArray[randomIndex]

    }

}
