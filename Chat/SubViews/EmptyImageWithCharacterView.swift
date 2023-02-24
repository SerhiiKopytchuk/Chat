//
//  EmptyImageWithCharacterView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 31.07.2022.
//

import SwiftUI

struct EmptyImageWithCharacterView: View {
    // MARK: - vars
    var text: String
    var colour: String
    var size: CGFloat
    var font: Font = Font.title.bold()

    // MARK: - body
    var body: some View {
        if let first = text.first {
            Text(String(first.uppercased()))
                .font(font)
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background {
                    Circle()
                        .fill(Color(colour))
                }
                .addLightShadow()
        }
    }

}

struct EmptyImageWithCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyImageWithCharacterView(text: "hello", colour: "Red", size: 40)
    }
}
