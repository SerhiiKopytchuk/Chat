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
                        .navigationTitle("chats")
                }else{
                    SignUpView()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear{
            viewModel.signedIn = viewModel.isSignedIn
        }
        .accentColor(.orange)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .previewInterfaceOrientation(.portrait)
    }
}


