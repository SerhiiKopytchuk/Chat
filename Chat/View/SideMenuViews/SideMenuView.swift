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

    // MARK: - vars
    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var messagingViewModel: MessagingViewModel
    @EnvironmentObject private var chattingViewModel: ChattingViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel
    @EnvironmentObject private var channelMessagingViewModel: ChannelMessagingViewModel

    @Binding var isShowingSideMenu: Bool
    @Binding var isShowingSearchUsers: Bool

    // MARK: - body

    var body: some View {

            Color.mainGradient
                .ignoresSafeArea()

            VStack {
                SideMenuHeaderView(isShowingSideMenu: $isShowingSideMenu)
                    .environmentObject(viewModel)
                    .foregroundColor(.white)
                    .frame(height: 240)

                ForEach(SideMenuViewModel.allCases, id: \.self) { option in

                    if option == SideMenuViewModel.profile {
                        NavigationLink {
                            EditProfileView()
                        } label: {
                            SideMenuOptionView(viewModel: option)
                        }
                    } else if option == SideMenuViewModel.createChannel {
                        NavigationLink {
                            CreateChannelView()
                                .environmentObject(viewModel)
                                .environmentObject(channelViewModel)
                        } label: {
                            SideMenuOptionView(viewModel: option)
                        }
                    } else if option == SideMenuViewModel.searchUsers {
                        NavigationLink {
                            SearchView()
                                .environmentObject(messagingViewModel)
                                .environmentObject(viewModel)
                                .environmentObject(chattingViewModel)
                                .environmentObject(channelViewModel)
                                .environmentObject(channelMessagingViewModel)
                                .navigationBarTitle("Search", displayMode: .automatic)
                        } label: {
                            SideMenuOptionView(viewModel: option)
                        }
                    } else {
                        Button {
                            if option == SideMenuViewModel.logout {
                                withAnimation {
                                    viewModel.signOut()
                                    viewModel.currentUser.chats = []
                                }
                            }
                        } label: {
                            SideMenuOptionView(viewModel: option)
                        }
                    }
                }
                Spacer()
            }
            .background {
                Color.mainGradient
                    .ignoresSafeArea()
            }
            .navigationBarHidden(true)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(isShowingSideMenu: .constant(true), isShowingSearchUsers: .constant(false))
            .environmentObject(UserViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChattingViewModel())

    }
}
