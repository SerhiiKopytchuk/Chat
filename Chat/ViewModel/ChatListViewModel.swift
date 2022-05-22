//
//  ChatsListViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.05.2022.
//

import Foundation

class ChatListViewModel: ObservableObject{
    @Published var chats:[Chat] = [
        Chat(name: "Anna", time: "21:44", lastMessage: "Hello"),
        Chat(name: "Tom", time: "20:32", lastMessage: "Buy some food"),
        Chat(name: "Toby", time: "13:34", lastMessage: "Lets meet today")
    ]
}

struct Chat:Identifiable{
    
    internal init(name: String, time: String, lastMessage: String) {
        self.name = name
        self.time = time
        self.lastMessage = lastMessage
    }
    
    let id = UUID()
    let name:String
    let time:String
    let lastMessage:String
}
