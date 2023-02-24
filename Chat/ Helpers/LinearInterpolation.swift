//
//  LinearInterpolation.swift
//  DynamicTabIndicator
//
//  Created by Serhii Kopytchuk on 18.02.2023.
//

import SwiftUI

/// A simple class that will be useful to do linear interpolation calculations for our Dynamic Tab animation
class LinearInterpolation {
    private var length: Int
    private var inputRange: [CGFloat]
    private var outputRange: [CGFloat]

    init(inputRange: [CGFloat], outputRange: [CGFloat]) {
        // safe check
        assert(inputRange.count == outputRange.count)
        self.length = inputRange.count - 1
        self.inputRange = inputRange
        self.outputRange = outputRange
    }

    // swiftlint:disable:next variable_name
    func calculate(for x: CGFloat) -> CGFloat {
        if x <= inputRange[0] { return outputRange[0] }

        for index in 1...length {
            // swiftlint:disable:next variable_name
            let x1 = inputRange[index - 1]
            // because we need the prev value for x1/x2 calculation, the starting range is 1 rather than 0
            // swiftlint:disable:next variable_name
            let x2 = inputRange[index]
            // swiftlint:disable:next variable_name
            let y1 = outputRange[index - 1]
            // swiftlint:disable:next variable_name
            let y2 = outputRange[index]

            // formula: y1 + ((y2 - y1) /(x2 - x1) * (x-x1)
            if x <= inputRange[index] {
                 // applying the formula to the nearest input range value.
                let result = y1 + ((y2 - y1) / (x2 - x1) * (x-x1))
                return result
            }
        }

        return outputRange[length]
    }
}
