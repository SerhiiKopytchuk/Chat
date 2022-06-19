//
//  ConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI

struct ConversationView: View {

    @State var user: User
    @State var isFindChat: Bool

    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        VStack {
            VStack {
                TitleRow(user: user)
                    .onTapGesture {
                        print(messagingViewModel.currentChat)
                    }
                if isFindChat {
                    ScrollViewReader { _ in
                        ScrollView {
                            ForEach(
                                self.messagingViewModel.currentChat.messages ?? [],
                                id: \.id) { message in
                                    MessageBubble(message: message)
                                }
                        }
                        .padding(.top, 10)
                        .background(.white)
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                    }
                } else {
                    VStack {
                        Button {
                            // sometimes get back, when creating chat
                            viewModel.createChat()
                        } label: {
                            Text("Start Chat")
                                .font(.title)
                                .padding()
                                .background(.white)
                                .cornerRadius(20)
                        }
                    }.frame(maxHeight: .infinity)
                }
            }
        }
        .background(Color("Peach"))
        MessageField()
            .environmentObject(messagingViewModel)
            .environmentObject(viewModel)
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(user: User(chats: [], gmail: "", id: "", name: ""), isFindChat: true)
    }
}
