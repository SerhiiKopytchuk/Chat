//
//  HeaderWithBackButton.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 30.07.2022.
//

import SwiftUI

struct HeaderWithBackButton: View {
    // MARK: - vars
    @Environment(\.self) var environment
    var text: String
    var backButtonPressed: () -> Void = {}
    // MARK: - body
    var body: some View {
        HStack(spacing: 15) {
            backButton

            Text(text)
                .font(.title.bold())
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - viewBuilders
    @ViewBuilder private var backButton: some View {
        Button {
            backButtonPressed()
            environment.dismiss()
        } label: {
            Image(systemName: "arrow.backward.circle.fill")
                .toButtonLightStyle(size: 40)
        }
    }
}

struct HeaderWithBackButton_Previews: PreviewProvider {
    static var previews: some View {
        HeaderWithBackButton(text: "")
    }
}
