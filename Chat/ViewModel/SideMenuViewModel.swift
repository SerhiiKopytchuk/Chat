//
//  SideMenuViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import Foundation

enum SideMenuViewModel: Int, CaseIterable {
    case profile
    case createChannel
    case searchUsers
    case subscriptions
    case logout

    var title: String {
        switch self {
        case .profile: return "Profile"
        case .createChannel: return "Create channel"
        case .searchUsers: return "Search users"
        case .subscriptions: return "Subscriptions"
        case .logout: return "Logout"
        }
    }

    var imageName: String {
        switch self {
        case .profile: return "person"
        case .createChannel: return "plus"
        case .searchUsers: return "magnifyingglass"
        case .subscriptions: return "star"
        case .logout: return "arrow.left.square"
        }
    }
}
