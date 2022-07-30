//
//  editProfileView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.06.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
import UIKit

struct EditProfileView: View {

    @State var profileImage: UIImage?
    @State var isShowingImagePicker = false
    @State var newName: String = ""

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true
    @State var isChangedImage = false

    @EnvironmentObject var userViewModel: UserViewModel
    @ObservedObject var editProfileView = EditProfileViewModel()

    @Environment (\.self) var env

    var body: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(colors: [
                        Color("Gradient1"),
                        Color("Gradient2"),
                        Color("Gradient3")
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            .ignoresSafeArea()

            VStack {

                HStack(spacing: 15) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "arrow.backward.circle.fill")
                            .toButtonLightStyle(size: 40)
                    }

                    Text("Edit profile")
                        .font(.title.bold())
                        .opacity(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                .padding()

                ZStack(alignment: .top) {
                    Color("BG")
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                        .offset(x: 0, y: 50)
                    VStack {
                        changeProfileImageButton

                        Label {
                            TextField("Enter your new name", text: $newName)
                                .padding(.leading, 10)
                        } icon: {
                            Image(systemName: "person")
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 15)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.white)
                        }
                        .padding(.top, 25)
                        .padding()

                        Text(userViewModel.currentUser.gmail)
                            .font(.callout)
                            .foregroundColor(.gray)
                            .padding()

                        Spacer()

                        saveButton
                            .padding()

                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            newName = userViewModel.currentUser.name
        }
        .onChange(of: profileImage ?? UIImage(), perform: { newImage in
            editProfileView.user = self.userViewModel.currentUser
            editProfileView.saveImage(image: newImage)
        })
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $profileImage)
        }
    }

    var changeProfileImageButton: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            if isFindUserImage {
                if self.profileImage != nil {
                    ZStack {
                        Image(uiImage: self.profileImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .addLightShadow()
                    }
                } else {
                    ZStack {
                        WebImage(url: imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .addLightShadow()
                    }
                }
            } else {
                if self.profileImage != nil {
                        Image(uiImage: self.profileImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .addLightShadow()
                } else {
                        emptyImage
                }
            }
        }
        .frame(width: 100, height: 100)
        .onAppear {
            let ref = Storage.storage().reference(withPath: userViewModel.currentUser.id )
            ref.downloadURL { url, err in
                if err != nil {
                    self.isFindUserImage = false
                    return
                }
                withAnimation(.easeInOut) {
                    self.imageUrl = url
                }
            }
        }
    }

    var emptyImage: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.black.opacity(0.70))
            .background(.white)
            .cornerRadius(50)
            .addLightShadow()
    }

    var saveButton: some View {
        Button {
            newName = newName.trim()
            if newName.count > 3 {
                editProfileView.changeName(newName: newName, userId: userViewModel.currentUser.id )
            }
        } label: {
            Text("save")
                .toButtonGradientStyle()
                .opacity(newName.isValidateLengthOfName() && newName != userViewModel.currentUser.name ? 1 : 0.6)
        }
        .disabled(newName.isValidateLengthOfName() && newName != userViewModel.currentUser.name ? false : true)
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(UserViewModel())
    }
}

extension View {
    func underlineTextField(text: String, underlineOn: Int) -> some View {
        self
            .padding(.vertical, 10)
            .overlay(
                Rectangle()
                    .frame(height: 2).padding(.top, 35)
                    .foregroundColor(text.count >= underlineOn ? .orange : .black)
            )
            .padding(10)
    }
}
