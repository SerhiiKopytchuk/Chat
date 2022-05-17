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
    
    @ObservedObject var viewModel: AppViewModel = AppViewModel()
    
    
    var body: some View {
        
        NavigationView{
            if viewModel.signedIn{
                MainView().navigationBarHidden(true).navigationBarBackButtonHidden(true)
            }else{
                SignUpView()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
.previewInterfaceOrientation(.portrait)
    }
}


