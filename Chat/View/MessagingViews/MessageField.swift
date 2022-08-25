//
//  MessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import Foundation

struct MessageField: View {

    @State var messageText: String = ""

    @State var height: CGFloat = 40

    @FocusState private var autoSizingTextFieldIsFocused: Bool

    @ObservedObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    var body: some View {
        HStack {

            ResizeableTextView(text: $messageText, height: $height, placeholderText: "Enter message")

            Button {
                messageText = messageText.trimmingCharacters(in: .newlines)
                messagingViewModel.sendMessage(text: messageText)
                messageText = ""
                UIApplication.shared.endEditing()
                autoSizingTextFieldIsFocused = false
                chattingViewModel.changeLastActivityAndSortChats()
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.gray)
                    .cornerRadius(15)
            }

            .frame(maxHeight: .infinity, alignment: .bottom)

        }
        .frame( height: height < 160 ? self.height : 160)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(15)
    }

}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool) -> Void = {_ in }
    var commit: () -> Void = {}

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .opacity(0.5)
            }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
