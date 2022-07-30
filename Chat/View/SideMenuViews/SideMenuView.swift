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

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @EnvironmentObject var channelMessagingViewModel: ChannelMessagingViewModel

    @Binding var isShowingSideMenu: Bool
    @Binding var isShowingSearchUsers: Bool

    var body: some View {
        ZStack {
            LinearGradient(gradient:
                            Gradient(colors: [
                               Color("Gradient1"),
                               Color("Gradient2"),
                               Color("Gradient3")
                            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
                    } else if option == SideMenuViewModel.createChannel {
                        NavigationLink {
                            CreateChannelView()
                                .environmentObject(viewModel)
                                .environmentObject(ChannelViewModel())
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
        }.navigationBarHidden(true)
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
