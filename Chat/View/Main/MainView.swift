//
//  MainView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 16.05.2022.
//

import SwiftUI
import Firebase

struct MainView: View {

    // MARK: - vars
    @State private var isShowingSideMenu = false
    @State private var showSearchUsers = false

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject private var presenceViewModel: PresenceViewModel

    @Environment(\.scenePhase) var scenePhase

    // MARK: - body
    var body: some View {
        ZStack {
            if isShowingSideMenu {
                SideMenuView(isShowingSideMenu: $isShowingSideMenu, isShowingSearchUsers: $showSearchUsers)
            }
            TabBarView(isShowingSideMenu: $isShowingSideMenu)
                .ignoresSafeArea(.all, edges: .bottom)
                .cornerRadius(isShowingSideMenu ? 20 : 10)
                .offset(x: isShowingSideMenu ? 300 : 0, y: isShowingSideMenu ? 44 : 0)
                .scaleEffect(isShowingSideMenu ? 0.8 : 1)
                .shadow(color: .black, radius: isShowingSideMenu ? 20 : 0)
        }
        .onChange(of: scenePhase, perform: { phase in
            if phase == .active {
                viewModel.getCurrentUser { user in
                    presenceViewModel.startSetup(user: user)
                }
            } else {
                presenceViewModel.setOffline()
            }
        })
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .onAppear {
            isShowingSideMenu = false
            chattingViewModel.currentUser = viewModel.currentUser
        }
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(UserViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChattingViewModel())
            .environmentObject(ChannelViewModel())
            .environmentObject(ChannelMessagingViewModel())
            .environmentObject(EditChannelViewModel())
    }
}
