//
//  Text + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 24.07.2022.
//

import Foundation
import SwiftUI

extension Text {

    func toButtonGradientStyle() -> some View {
        return self.font(.title3)
                .fontWeight(.semibold)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(colors: [
                                Color("Gradient1"),
                                Color("Gradient2"),
                                Color("Gradient3")
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
                .foregroundColor(.white)
                .padding(.bottom, 10)
    }
}
