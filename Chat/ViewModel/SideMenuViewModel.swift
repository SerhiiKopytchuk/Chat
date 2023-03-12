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
    case search
    case logout

    var title: String {
        switch self {
        case .profile: return "Profile"
        case .createChannel: return "Create channel"
        case .search: return "Search"
        case .logout: return "Logout"
        }
    }

    var imageName: String {
        switch self {
        case .profile: return "person"
        case .createChannel: return "plus"
        case .search: return "magnifyingglass"
        case .logout: return "arrow.left.square"
        }
    }
}
