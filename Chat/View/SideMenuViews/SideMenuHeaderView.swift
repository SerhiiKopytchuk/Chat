//
//  SideMenuHeaderView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import SDWebImageSwiftUI
struct SideMenuHeaderView: View {

    @Binding var isShowingSideMenu: Bool
    @EnvironmentObject var viewModel: UserViewModel
    @State var user: User = User()
    @State var myImageUrl = URL(string: "")
    @State var isFindUserImage = true

    var imageSize: CGFloat = 65
    let ref = Storage.storage().reference(withPath: Auth.auth().currentUser?.uid ?? "someId")

    var body: some View {

        ZStack(alignment: .topTrailing) {
            Button {
                withAnimation(.spring()) {
                    isShowingSideMenu.toggle()
                }
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 32, height: 32)
                    .padding()
            }

            VStack(alignment: .leading) {

                userImage

                Text(user.name)
                    .font(.system(size: 24, weight: .semibold))

                Text(user.gmail)
                    .font(.system(size: 14 ))
                    .padding(.bottom, 24)
                HStack {
                    HStack {
                        Text("\(viewModel.currentUser.chats.count)").bold()
                        Text(viewModel.currentUser.chats.count == 1 ? "Chat" : "Chats")
                    }
                    HStack {
                        Text("\(viewModel.currentUser.channels.count)").bold()
                        Text(viewModel.currentUser.channels.count == 1 ? "Channel" : "Channels")
                    }
                    Spacer()
                }
                Spacer()
            }.padding()
        }
        .onAppear {
            self.viewModel.getCurrentUser { user in
                withAnimation {
                    self.user = user
                }
            }
        }
    }

    @ViewBuilder var userImage: some View {
        if isFindUserImage {
            WebImage(url: myImageUrl)
                .resizable()
                .scaledToFill()
                .clipped()
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
                .padding(.bottom, 16)
                .addLightShadow()
                .onAppear {
                    ref.downloadURL { url, err in
                        if err != nil {
                            self.isFindUserImage = false
                            return
                        }
                        withAnimation(.easeInOut) {
                            self.myImageUrl = url
                        }
                    }
                }
        } else {
            if let first = user.name.first {
                Text(String(first.uppercased()))
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .frame(width: imageSize, height: imageSize)
                    .background {
                        Circle()
                            .fill(Color(user.colour))
                    }
                    .padding(.bottom, 16)
                    .addLightShadow()
            }
        }
    }
}

struct SideMenuHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuHeaderView(isShowingSideMenu: .constant(true))
            .environmentObject(UserViewModel())
    }
}
