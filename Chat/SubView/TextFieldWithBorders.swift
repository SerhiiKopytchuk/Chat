//
//  TextFieldWithBorders.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 11.03.2023.
//

import SwiftUI

struct TextFieldWithBorders: View {

    // MARK: - Variables
    var iconName: String
    var placeholderText: String
    @Binding var text: String
    var color: Color = Color.secondPrimary

    // MARK: - body
    var body: some View {
        Label {
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholderText)
                        .foregroundColor(color)
                        .opacity(0.8)
                }
                .autocorrectionDisabled()
                .padding(.leading, 10)
                .foregroundColor(color)
                .accentColor(color)
        } icon: {
            Image(systemName: iconName)
                .foregroundColor(color)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color, lineWidth: 1)
        }
    }

    // MARK: - ViewBuilders

    // MARK: - functions

}

#if DEBUG
struct TextFieldWithBorders_Previews: PreviewProvider {
    @State static var text: String = "some text"
    static var previews: some View {
        TextFieldWithBorders(iconName: "person", placeholderText: "Placeholder text", text: $text)
    }
}
#endif
