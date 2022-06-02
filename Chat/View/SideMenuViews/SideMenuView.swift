//
//  SideMenuView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import SwiftUI
import Firebase


struct SideMenuView: View {
    @EnvironmentObject var viewModel:AppViewModel
    @Binding var isShowingSideMenu: Bool
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.orange, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack{
                SideMenuHeaderView(isShowingSideMenu: $isShowingSideMenu)
                    .foregroundColor(.white)
                    .frame(height: 240)
                ForEach(SideMenuViewModel.allCases, id: \.self){ option in
                    Button {
                        if option == SideMenuViewModel.logout{
                            withAnimation (){
                                viewModel.signOut()
                            }
                        }
                        if option == SideMenuViewModel.profile{
//                            viewModel.printUserId()
                        }
                    } label: {
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
