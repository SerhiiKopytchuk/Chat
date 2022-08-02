//
//  HeaderWithBackButton.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 30.07.2022.
//

import SwiftUI

struct HeaderWithBackButton: View {

    @Environment(\.self) var environment
    var text: String

    var body: some View {
        HStack(spacing: 15) {
            Button {
                environment.dismiss()
            } label: {
                Image(systemName: "arrow.backward.circle.fill")
                    .toButtonLightStyle(size: 40)
            }

            Text(text)
                .font(.title.bold())
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct HeaderWithBackButton_Previews: PreviewProvider {
    static var previews: some View {
        HeaderWithBackButton(text: "")
    }
}
