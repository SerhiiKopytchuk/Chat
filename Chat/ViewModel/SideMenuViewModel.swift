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
    case searchUsers
    case notifications
    case logout
    
    var title: String{
        switch self{
        case .profile: return "Profile"
        case .bookmarks: return "Bookmarks"
        case .searchUsers: return "Search"
        case .notifications: return "Notifications"
        case .logout: return "Logout"
        }
    }
    
    var imageName: String{
        switch self{
        case .profile: return "person"
        case .bookmarks: return "bookmark"
        case .searchUsers: return "magnifyingglass"
        case .notifications: return "bell"
        case .logout: return "arrow.left.square"
        }
    }
}
