//
//  MessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI

struct MessageField: View {
    @State private var message = ""

    @ObservedObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    var body: some View {
        HStack {
            CustomTextField(placeholder: Text("Enter your message here"), text: $message)

            Button {
                messagingViewModel.sendMessage(text: message)
                message = ""
                chattingViewModel.getChats(fromUpdate: true)
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.gray)
                    .cornerRadius(15)
            }

        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("BG"))
        .cornerRadius(15)
        .padding()
    }
}

struct MessageField_Previews: PreviewProvider {
    static var previews: some View {
        MessageField(messagingViewModel: MessagingViewModel())
            .environmentObject(UserViewModel())
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
