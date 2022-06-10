//
//  ConversationListRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.05.2022.
//
import Foundation
import SwiftUI

struct ConversationListRow: View {
    // Inject properties into the struct
    @EnvironmentObject var viewModel: AppViewModel
    @State var person: User?
    let chat: Chat

    let rowTapped: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "person")
                .padding(.trailing)
            VStack(alignment: .leading) {
                HStack {
                    Text(person?.name ?? "")
                    Spacer()
                    Text("12:34")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(person?.gmail ?? "")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 40)
            .onTapGesture {
                rowTapped()
            }
            .onAppear {
                self.viewModel.getUserByChat(chat: self.chat) { user in
                    withAnimation {
                        self.person = user
                    }
                }
            }
    }

}
