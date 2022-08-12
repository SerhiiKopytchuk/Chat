//
//  MessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI

struct MessageField: View {
    @Binding var messageText: String

    @State var height: CGFloat = 40
    let heightOfOneRow: CGFloat = 25

    @ObservedObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    var body: some View {
        HStack {

            ZStack {
                TextEditor(text: $messageText)
                    .frame(height: height)
                Text(messageText).opacity(0).padding(.all, 8)
                    .frame(height: height)
                    .onChange(of: self.messageText) { _ in
                        getHeightOfTextEditor()
                    }
                    .onAppear {

                    }

            }

//            CustomTextField(placeholder: Text("Enter your message here"), text: $message)

            Button {
                messagingViewModel.sendMessage(text: messageText)
                messageText = ""

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
        .frame(height: height)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(15)
    }

    private func getHeightOfTextEditor() {
        let linesCount = messageText.reduce(into: 0) { count, letter in
            if letter == "\n" {
                count += 1
            }
        }

        if linesCount == 0 {
            withAnimation {
                self.height = CGFloat(40)
            }
        } else if linesCount <= 5 {
            withAnimation {
                self.height = CGFloat( CGFloat(linesCount) * heightOfOneRow + heightOfOneRow)
            }
        } else {
            withAnimation {
                self.height = CGFloat( CGFloat(5) * heightOfOneRow + heightOfOneRow)
            }
        }

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
