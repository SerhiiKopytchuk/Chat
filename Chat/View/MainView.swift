//
//  MainView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 16.05.2022.
//

import SwiftUI
import Firebase

struct MainView: View {

    @State private var isShowingSideMenu = false
    @State private var showSearchUsers = false

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel
    @EnvironmentObject var editChannelViewModel: EditChannelViewModel

    var body: some View {
        ZStack {
            if isShowingSideMenu {
                SideMenuView(isShowingSideMenu: $isShowingSideMenu, isShowingSearchUsers: $showSearchUsers)
                    .environmentObject(messagingViewModel)
                    .environmentObject(viewModel)
                    .environmentObject(chattingViewModel)
                    .environmentObject(channelViewModel)
                    .environmentObject(channelMessagingViewModel)
            }
            TabBarView()
                .cornerRadius(isShowingSideMenu ? 20 : 10)
                .offset(x: isShowingSideMenu ? 300 : 0, y: isShowingSideMenu ? 44 : 0)
                .scaleEffect(isShowingSideMenu ? 0.8 : 1)
                .navigationBarItems(leading: Button(action: {
                    withAnimation(.spring()) {
                        isShowingSideMenu.toggle()
                    }
                }, label: {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.black)
                }) )
                .shadow(color: .black, radius: isShowingSideMenu ? 20 : 0)
                .environmentObject(messagingViewModel)
                .environmentObject(viewModel)
                .environmentObject(chattingViewModel)
                .environmentObject(channelViewModel)
                .environmentObject(channelMessagingViewModel)
                .environmentObject(editChannelViewModel)

        }
        .background {
            Color("BG")
                .ignoresSafeArea()
        }
        .onAppear {
            isShowingSideMenu = false
            chattingViewModel.currentUser = viewModel.currentUser
        }
        .navigationViewStyle(.columns)

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
