//
//  MainView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 16.05.2022.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack{
            Text("Chats")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(.orange)
                .padding()
                Spacer()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

