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
    
    // MARK: - vars
    
    @State private var launchScreenOpacity: CGFloat = 1
    @State private var launchScreenIconScale: CGFloat = 1
    
    @EnvironmentObject var viewModel: UserViewModel
    
    // MARK: - body
    var body: some View {
        
        NavigationStack {
            VStack {
                if viewModel.signedIn {
                    MainView()
                } else {
                    SignUpView()
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .navigationBarBackButtonHidden(true)
        }
        .overlay(alignment: .center, content: {
            ZStack {
                
                Color.background
                    .ignoresSafeArea()
                
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .scaleEffect(launchScreenIconScale, anchor: .center)
                
            }
            .ignoresSafeArea()
            .opacity(launchScreenOpacity)
        })
        .onAppear {
            viewModel.signedIn = viewModel.isSignedIn
            
            withAnimation(.easeOut) {
                launchScreenIconScale = 0.8
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                launchScreenOpacity = 0
            }
        }
    }
}
