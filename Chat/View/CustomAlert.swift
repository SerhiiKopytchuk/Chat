//
//  CustomAllert.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import Foundation
import SwiftUI

struct customAlert:View{
    
    @Binding var show:Bool
    @Binding var text:String
    
    @EnvironmentObject var viewModel: AppViewModel

    
    var body: some View{
        VStack{
            Text("Error")
                
                .font(.system(.title, design: .rounded))
                .padding()
                .foregroundColor(.white)
            Text(text)
                .font(.body)
                .padding()
                .foregroundColor(.white)
                .frame(alignment: .center)
            Button {
                withAnimation {
                    show = false
                    viewModel.showAlert = false
                }
            } label: {
                Text("Close")
            }
            .padding()
            .padding(.horizontal, 60)
            .background(.white)
            .cornerRadius(20)

        }
        .padding()
        .padding(.horizontal, 40)
        .background(.brown)
        .cornerRadius(30)

    }
}
