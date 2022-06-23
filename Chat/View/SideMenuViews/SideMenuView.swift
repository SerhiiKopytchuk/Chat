//
//  SideMenuView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import SwiftUI
import Firebase
import Contacts

struct SideMenuView: View {

    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    @Binding var isShowingSideMenu: Bool
    @Binding var isShowingSearchUsers: Bool

    var body: some View {
        ZStack {
            LinearGradient(gradient:
                            Gradient(colors: [.orange, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack {
                SideMenuHeaderView(isShowingSideMenu: $isShowingSideMenu)
                    .foregroundColor(.white)
                    .frame(height: 240)
                ForEach(SideMenuViewModel.allCases, id: \.self) { option in

                    if option == SideMenuViewModel.profile {
                        NavigationLink {
                            EditProfileView()
                        } label: {
                            SideMenuOptionView(viewModel: option)
                        }
                    } else if option == SideMenuViewModel.searchUsers {
                        NavigationLink {
                            SearchUsersView()
                                .environmentObject(messagingViewModel)
                                .environmentObject(viewModel)
                                .environmentObject(chattingViewModel)
                                .navigationBarTitle("Search Users", displayMode: .automatic)
                        } label: {
                            SideMenuOptionView(viewModel: option)
                        }
                    } else {
                        Button {
                            if option == SideMenuViewModel.logout {
                                withAnimation {
                                    viewModel.signOut()
                                    chattingViewModel.chats = []
                                }
                            }
                        } label: {
                            SideMenuOptionView(viewModel: option)
                        }
                    }
                }
                Spacer()
            }
        }.navigationBarHidden(true)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(isShowingSideMenu: .constant(true), isShowingSearchUsers: .constant(false))
            .environmentObject(AppViewModel())
    }
}
