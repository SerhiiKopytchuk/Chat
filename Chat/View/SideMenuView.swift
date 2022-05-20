//
//  SideMenuView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import SwiftUI

struct SideMenuView: View {
    
    @Binding var isShowingSideMenu: Bool
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack{
                SideMenuHeaderView(isShowingSideMenu: $isShowingSideMenu)
                    .foregroundColor(.white)
                    .frame(height: 240)
                
                ForEach(SideMenuViewModel.allCases, id: \.self){ option in
                        NavigationLink(destination: Text(option.title)) {
                            SideMenuOptionView(viewModel: option)
                        }
                }
                Spacer()
            }
        }.navigationBarHidden(true)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(isShowingSideMenu: .constant(true))
    }
}
