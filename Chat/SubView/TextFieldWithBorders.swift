//
//  TextFieldWithBorders.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 11.03.2023.
//

import SwiftUI

struct TextFieldWithBorders: View {

    // MARK: - Variables
    var placeholderText: String
    @Binding var text: String

    // MARK: - body
    var body: some View {
        Label {
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholderText)
                        .foregroundColor(Color.secondPrimary)
                        .opacity(0.8)
                }
                .autocorrectionDisabled()
                .padding(.leading, 10)
                .foregroundColor(Color.secondPrimary)
                .accentColor(Color.secondPrimary)
        } icon: {
            Image(systemName: "person")
                .foregroundColor(Color.secondPrimary)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.secondPrimary, lineWidth: 1)
        }
        .padding()
    }

    // MARK: - ViewBuilders

    // MARK: - functions

}

#if DEBUG
struct TextFieldWithBorders_Previews: PreviewProvider {
    @State static var text: String = "some text"
    static var previews: some View {
        TextFieldWithBorders(placeholderText: "Placeholder text", text: $text)
    }
}
#endif
