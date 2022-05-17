//
//  ChatApp.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.05.2022.
//

import SwiftUI
import Firebase

@main
struct ChatApp: App {

    init() {
        FirebaseApp.configure()
      }
    
    var body: some Scene {
        WindowGroup {
            
            let ViewModel = AppViewModel()
            RootView()
                .environmentObject(ViewModel)
        }
        
    }
}
