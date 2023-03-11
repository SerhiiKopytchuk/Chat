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
        Text(text.uppercased())
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .leading) {
                backButton
                    .padding(.horizontal)
            }
    }

    // MARK: - viewBuilders
    @ViewBuilder private var backButton: some View {
        Button {
            backButtonPressed()
            environment.dismiss()
        } label: {
            Image(systemName: "arrow.backward")
                .imageScale(.large)
        }
    }
}

struct HeaderWithBackButton_Previews: PreviewProvider {
    static var previews: some View {
        HeaderWithBackButton(text: "")
    }
}
