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
    @EnvironmentObject private var presenceViewModel: PresenceViewModel

    @Binding var isShowingSideMenu: Bool

    @State var sidebarOffset: CGFloat = -10
    @Binding var sideBarAdditionSpace: CGFloat

    // MARK: - computed properties

    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    // MARK: - body

    var body: some View {
        VStack(alignment: .leading) {
            SideMenuHeaderView()
                .environmentObject(viewModel)
                .foregroundColor(.white)
                .padding(.leading, sideBarAdditionSpace + 20)

            ForEach(SideMenuViewModel.allCases, id: \.self) { option in

                if option == SideMenuViewModel.logout {
                    Button {
                        if option == SideMenuViewModel.logout {
                            withAnimation {
                                presenceViewModel.setOffline()
                                viewModel.signOut()
                                viewModel.currentUser.chats = []
                            }
                        }
                    } label: {
                        SideMenuOptionView(viewModel: option)
                    }
                } else {
                    NavigationLink(value: option) {
                        SideMenuOptionView(viewModel: option)
                    }
                }
            }
            .padding(.leading, sideBarAdditionSpace + 20)

            Spacer()
        }
        .navigationDestination(for: SideMenuViewModel.self, destination: { option in
            switch option {
            case .profile:
                EditProfileView()
            case .search:
                SearchView()
            case .createChannel:
                CreateChannelView()
            default:
                Text("Sorry. This feature in development.")
            }
        })
        .background {
            Rectangle()
                .fill(.thinMaterial)
                .environment(\.colorScheme, .dark)
                .ignoresSafeArea()

        }
        .offset(x: sidebarOffset)
        .gesture(
            DragGesture()
                .onChanged({ value in
                    if value.translation.width <= 0 {
                        sidebarOffset = (value.translation.width - 10)
                    }
                })
                .onEnded({ value in
                    if abs(value.translation.width) < (screenWidth / 3) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            sidebarOffset = -sideBarAdditionSpace
                        }
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isShowingSideMenu = false
                            sidebarOffset = -sideBarAdditionSpace
                        }
                    }
                })
        )
        .frame(width: screenWidth * 3 / 4 + sideBarAdditionSpace)
        .navigationBarHidden(true)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(UserViewModel())
            .environmentObject(MessagingViewModel())
            .environmentObject(ChattingViewModel())
            .environmentObject(ChannelViewModel())
            .environmentObject(ChannelMessagingViewModel())
            .environmentObject(EditChannelViewModel())
            .preferredColorScheme(.dark)
    }
}
