//
//  Optional + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 22.11.2022.
//

import SwiftUI
import Firebase

extension Optional where Wrapped: Error {
    func review(message: String) -> Bool {
        if let self {
            print(message + self.localizedDescription)
            return true
        }
        return false
    }

    func review(result: AuthDataResult?, failure: () -> Void) -> Bool {
        if result == nil, self != nil {
            failure()
            return true
        } else {
            return false
        }
    }
}
