//
//  CustomSocialButton.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 03.04.2023.
//

import SwiftUI

struct CustomSocialButton: View {
    var image: String
    var text: String
    var color: Color
    var action: (() -> Void)?

    var body: some View {
        Button(
            action: {
                action?()
            },
            label: {
                HStack {
                    Image(image)
                        .resizable()
                        .frame(width: 20, height: 20)

                    Text(text)
                        .bold()
                        .foregroundColor(Color.primary)

                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(RoundedRectangle(cornerRadius: 8).fill(color))
            })
    }
}

#if DEBUG
struct CustomSocialButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomSocialButton(image: "google", text: "Sign up with Google", color: .primary)
    }
}
#endif
