//
//  MainView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 16.05.2022.
//

import SwiftUI
import Firebase

struct MainView: View {
    
    @EnvironmentObject var viewModel: AppViewModel

    
    var body: some View {
        NavigationView{
            VStack{
                Button {
                    try! Auth.auth().signOut()
                    viewModel.signedIn = false
                } label: {
                    Text("Sign Out")
                        .padding(15)
                        .foregroundColor(.white)
                        .background(.brown)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                        
                        
                }


                Text("Chats")
                    .font(.system(.largeTitle, design: .rounded))
                    .foregroundColor(.orange)
                    .padding()
                Spacer()
            }
        }.navigationBarHidden(true).navigationBarBackButtonHidden(true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

