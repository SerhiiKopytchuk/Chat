//
//  ChatApp.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.05.2022.
//

import SwiftUI
import FirebaseCore

@main
struct ChatApp: App {
    
    init() {
        FirebaseApp.configure()
      }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        
    }
}
