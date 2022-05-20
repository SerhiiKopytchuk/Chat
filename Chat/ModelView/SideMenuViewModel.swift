//
//  SideMenuViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import Foundation

enum SideMenuViewModel: Int ,CaseIterable{
    case profile
    case bookmarks
    case messages
    case notifications
    case logout
    
    var title: String{
        switch self{
        case .profile: return "Profile"
        case .bookmarks: return "Bookmarks"
        case .messages: return "Messages"
        case .notifications: return "Notifications"
        case .logout: return "Logout"
        }
    }
    
    var imageName: String{
        switch self{
        case .profile: return "person"
        case .bookmarks: return "bookmark"
        case .messages: return "bubble.left"
        case .notifications: return "bell"
        case .logout: return "arrow.left.square"
        }
    }
}
