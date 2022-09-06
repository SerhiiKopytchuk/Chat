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

    @State var isShowAlert = false

    let imageSize: CGFloat = 100

    @EnvironmentObject var userViewModel: UserViewModel
    @ObservedObject var editProfileViewModel = EditProfileViewModel()
    @ObservedObject var imageViewModel = ImageViewModel()

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

                HeaderWithBackButton(environment: _env, text: "Edit profile")
                    .padding()

                ZStack(alignment: .top) {

                    Color("BG")
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                        .offset(x: 0, y: 50)

                    VStack {
                        changeProfileImageButton

                        userNameTextField

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

            customAlert
        }
        .navigationBarHidden(true)
        .onAppear {
            newName = userViewModel.currentUser.name
        }
        .onChange(of: profileImage ?? UIImage(), perform: { newImage in
            editProfileViewModel.user = self.userViewModel.currentUser
            imageViewModel.saveProfileImage(image: newImage, userId: editProfileViewModel.user.id)
        })
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $profileImage)
        }
    }

    @ViewBuilder var changeProfileImageButton: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            if isFindUserImage {
                if self.profileImage != nil {
                    ZStack {
                        Image(uiImage: self.profileImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
                    }
                } else {
                    ZStack {
                        WebImage(url: imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
                    }
                }
            } else {
                if self.profileImage != nil {
                        Image(uiImage: self.profileImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
                } else {
                    EmptyImageWithCharacterView(text: userViewModel.currentUser.name,
                                                colour: userViewModel.currentUser.colour,
                                                size: imageSize)
                }
            }
        }
        .frame(width: imageSize, height: imageSize)
        .onAppear {
            imageSetup()
        }
    }

    private func imageSetup() {
        let ref = StorageReferencesManager.shared.getProfileImageReference(userId: userViewModel.currentUser.id)
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

    @ViewBuilder var userNameTextField: some View {
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
    }

    @ViewBuilder var saveButton: some View {
        Button {

            if !newName.isValidateLengthOfName() {
                self.isShowAlert = true
                return
            }

            newName = newName.trim()
            if newName.count > 3 {
                editProfileViewModel.changeName(newName: newName, userId: userViewModel.currentUser.id )
            }
        } label: {
            Text("save")
                .toButtonGradientStyle()
                .opacity(newName.isValidateLengthOfName() && newName != userViewModel.currentUser.name ? 1 : 0.6)
        }
        .disabled(newName != userViewModel.currentUser.name ? false : true)
    }

    @ViewBuilder var customAlert: some View {
        if isShowAlert {
            GeometryReader { geometry in
                CustomAlert(show: $isShowAlert, text: newName.count > 3 ?
                                "Name should be shorter than 35 symbols" :
                                "Name should be longer than 3 symbols")

                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                .frame(maxWidth: geometry.frame(in: .local).width - 20)
            }
            .background(Color.white.opacity(0.65))
            .edgesIgnoringSafeArea(.all)
        }
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
