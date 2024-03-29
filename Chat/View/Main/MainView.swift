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

    // MARK: - computed properties

    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    // MARK: - body
    var body: some View {
        ZStack {

            TabBarView(isShowingSideBar: $isShowingSideMenu)
                .ignoresSafeArea(.all, edges: .bottom)

            SideMenuView(isShowingSideMenu: $isShowingSideMenu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shadow(radius: isShowingSideMenu ? 20 : 0)
                .offset(x: !isShowingSideMenu ? -screenWidth * 3/4 : 0)
                .background {
                    if isShowingSideMenu {
                        Color.black.opacity(0.15)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isShowingSideMenu = false
                                }
                            }
                    }
                }
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
//            .preferredColorScheme(.dark)
    }
}
