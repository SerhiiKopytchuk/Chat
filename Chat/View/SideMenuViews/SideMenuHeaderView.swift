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
    @EnvironmentObject var viewModel: AppViewModel
    @State var user: User = User(chats: [], gmail: "", id: "", name: "")
    @State var myImageUrl = URL(string: "")
    @State var isFindUserImage = true
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
                if isFindUserImage {
                    WebImage(url: myImageUrl)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                        .padding(.bottom, 16)
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
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                        .padding(.bottom, 16)
                }

                Text(user.name)
                    .font(.system(size: 24, weight: .semibold))

                Text(user.gmail)
                    .font(.system(size: 14 ))
                    .padding(.bottom, 24)
                HStack {
                    HStack {
                        Text("12").bold()
                        Text("Chats")
                    }
                    HStack {
                        Text("4").bold()
                        Text("Chanels")
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
}

struct SideMenuHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuHeaderView(isShowingSideMenu: .constant(true))
            .environmentObject(AppViewModel())
    }
}
