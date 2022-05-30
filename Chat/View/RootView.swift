//
//  ContentView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.05.2022.
//

import SwiftUI
import Firebase
// Apple HIG
// Apple Human Interface Guidelines

// SF Symbols
struct RootView: View {
    
    @EnvironmentObject var viewModel:AppViewModel
    
    var body: some View {
        
        NavigationView{
            VStack{
                if viewModel.signedIn{
                    MainView()
                        .navigationViewStyle(.stack)
                        .navigationBarTitle("Chats")
                        
                }else{
                    SignUpView()        
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .accentColor(.orange)
        .onAppear{
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}



