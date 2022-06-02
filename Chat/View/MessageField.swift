//
//  MessageField.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI

struct MessageField: View {
    @State private var message = ""
    @EnvironmentObject var messagesManager:AppViewModel
    
    var body: some View {
        HStack{
            CustomTextField(placeholder: Text("Enter your message here"), text: $message)
            
            Button {
                messagesManager.sendMessage(text: message)
                message = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("Peach"))
                    .cornerRadius(50)
            }

        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("Gray"))
        .cornerRadius(50)
        .padding()
    }
}

struct MessageField_Previews: PreviewProvider {
    static var previews: some View {
        MessageField()
            .environmentObject(AppViewModel())
    }
}

struct CustomTextField: View{
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool) -> () = {_ in }
    var commit: () -> () = {}
    
    var body: some View{
        ZStack(alignment: .leading){
            if text.isEmpty{
                placeholder
                    .opacity(0.5)
            }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}

