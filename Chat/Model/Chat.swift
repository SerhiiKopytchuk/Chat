//
//  Chat.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 05.06.2022.
//

import Foundation


struct Chat: Codable, Identifiable{
    var id:String
    var user1Id:String
    var user2Id:String
    var messages:[Message]
}

struct ChatPart: Codable, Identifiable{
    var id:String
    var user1Id:String
    var user2Id:String
}
