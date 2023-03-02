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
import PhotosUI

struct EditProfileView: View {
    // MARK: - vars
    @State private var profileImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var newName: String = ""

    @State private var isAnimate = false

    // MARK: image properties
    @State private var imageUrl = URL(string: "")
    @State private var isFindUserImage = true
    private let imageSize: CGFloat = 100

    @State private var isShowAlert = false
    @State private var alertTitle = ""
    @State private var alertText = ""

    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var chattingViewModel: ChattingViewModel
    @EnvironmentObject private var viewModel: UserViewModel
    @ObservedObject var editProfileViewModel = EditProfileViewModel()
    @ObservedObject private var imageViewModel = ImageViewModel()

    @Environment (\.self) var env

    // MARK: - computed vars
    private var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }

    // MARK: - body
    var body: some View {
        ZStack(alignment: .center) {

            Color.background
                .ignoresSafeArea()

            VStack {

                header

                Spacer()

                changeProfileImageButton

                Text(userViewModel.currentUser.name)
                    .foregroundColor(Color.secondPrimaryReversed)
                    .font(.headline)
                    .padding(.top, 10)

                Text(userViewModel.currentUser.gmail)
                    .foregroundColor(Color.secondPrimaryReversed)
                    .font(.callout)
                    .fontWeight(.light)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.secondPrimaryReversed)
                        .ignoresSafeArea()

                    VStack {

                        HStack {
                            Spacer()
                            chatsImagesView
                            Spacer()
                            channelsImagesView
                            Spacer()
                        }
                        .opacity(isAnimate ? 1 : 0)
                        .frame(maxWidth: .infinity)

                        Spacer()

                        Divider()
                            .overlay(Color.secondPrimary)

                        userNameTextField

                        Spacer()

                        saveButton

                    }

                }
                .frame(height: screenSize.height/3)
                .offset(y: isAnimate ? 0 : screenSize.height/3)

            }

        }
        .overlay(content: {
            customAlert
        })
        .addRightGestureRecognizer {
            env.dismiss()
        }
        .navigationBarHidden(true)
        .onAppear {
            newName = userViewModel.currentUser.name
            withAnimation(.easeOut(duration: 0.45)) {
                isAnimate = true
            }
        }
        .onChange(of: profileImage ?? UIImage(), perform: { newImage in
            imageViewModel.saveProfileImage(image: newImage,
                                            userId: userViewModel.currentUser.id)
        })
        .sheet(isPresented: $isShowingImagePicker, content: {
            CustomImagePicker(onSelect: { assets in
                parseImages(with: assets)
            },
                              isPresented: $isShowingImagePicker,
                              maxAmountOfImages: 1,
                              imagePickerModel: ImagePickerViewModel())
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        })
    }

    // MARK: - ViewBuilders

    @ViewBuilder private var header: some View {
        HStack {
            Button {
                env.dismiss()
            } label: {
                Image(systemName: "arrow.backward")
                    .imageScale(.large)
            }

            Spacer()

            Text("Profile".uppercased())
                .fontWeight(.medium)

            Spacer()

            Image(systemName: "arrow.backward")
                .imageScale(.large)
                .opacity(0)

        }
        .offset(y: isAnimate ? 0 : -screenSize.height/4)
        .padding(.horizontal)
    }

    @ViewBuilder private var chatsImagesView: some View {
        VStack {
            Text("Chats")
                .font(.headline)
                .fontWeight(.light)
                .foregroundColor(Color.secondPrimary)
            CoupleChatsImagesRow()
        }
        .padding()
    }

    @ViewBuilder private var channelsImagesView: some View {
        VStack {
            Text("Channels")
                .font(.headline)
                .fontWeight(.light)
                .foregroundColor(Color.secondPrimary)
            CoupleChannelsImagesInRow()
        }
        .padding()
    }

    @ViewBuilder private var changeProfileImageButton: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.secondPrimaryReversed, lineWidth: 3)
                    .frame(width: imageSize + 2, height: imageSize + 2)

                if self.profileImage != nil {
                    ZStack {
                        Image(uiImage: self.profileImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
                    }
                } else if isFindUserImage {
                    WebImage(url: imageUrl)
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

                Image(systemName: "camera")
                    .imageScale(.small)
                    .background {
                        Circle()
                            .fill(Color.secondPrimaryReversed)
                            .frame(width: 25, height: 25)
                    }
                    .foregroundColor(Color.secondPrimary)
                    .offset(x: imageSize/2 - 15, y: imageSize/2 - 15)
            }
        }
        .frame(width: imageSize, height: imageSize)
        .transition(.opacity)
        .onAppear {
            imageStartSetup()
        }
    }

    @ViewBuilder private var userNameTextField: some View {
        Label {
            TextField("", text: $newName)
                .placeholder(when: newName.isEmpty) {
                    Text("Enter your new name")
                        .foregroundColor(Color.secondPrimary)
                        .opacity(0.8)
                }
                .autocorrectionDisabled()
                .padding(.leading, 10)
                .foregroundColor(Color.secondPrimary)
                .accentColor(Color.secondPrimary)
        } icon: {
            Image(systemName: "person")
                .foregroundColor(Color.secondPrimary)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.secondPrimary, lineWidth: 1)
        }
        .padding()
    }

    @ViewBuilder private var saveButton: some View {
        Button {

            if !newName.isValidateLengthOfName() {
                alertTitle = "Failure"
                alertText = newName.count > 3 ?
                                "Name should be shorter than 35 symbols" :
                                "Name should be longer than 3 symbols"
                withAnimation {
                    self.isShowAlert = true
                }
                return
            }

            newName = newName.trim()
            if newName.count > 3 {
                editProfileViewModel.changeName(newName: newName, userId: userViewModel.currentUser.id )
                alertText = "Name was changed successfully"
                alertTitle = "Success"
                withAnimation {
                    self.isShowAlert = true
                }
            }
        } label: {
            Text("save")
                .font(.title3)
                .fontWeight(.light)
                .foregroundColor(Color.secondPrimary)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 15)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.secondPrimary, lineWidth: 1)
                }
                .padding(.horizontal)
                .opacity(newName.isValidateLengthOfName() && newName != userViewModel.currentUser.name ? 1 : 0.6)
        }
            .padding(.bottom)
    }

    @ViewBuilder private var customAlert: some View {
        if isShowAlert {
            GeometryReader { geometry in
                CustomAlert(isShow: $isShowAlert, title: alertTitle, text: alertText, type: .failure)
                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                .frame(maxWidth: geometry.frame(in: .local).width - 40)
            }
            .background(Color.black.opacity(0.65))
            .edgesIgnoringSafeArea(.all)
        }
    }

    // MARK: - functions
    private func imageStartSetup() {
        let ref = StorageReferencesManager.shared.getProfileImageReference(userId: userViewModel.currentUser.id)
        ref.downloadURL { url, err in
            if err != nil {
                withAnimation(.easeInOut) {
                    self.isFindUserImage = false
                }
                return
            }
            withAnimation(.easeInOut) {
                self.imageUrl = url
            }
        }
    }

    func parseImages(with assets: [PHAsset]) {
        guard !assets.isEmpty else { return }
        isShowingImagePicker = false

        let manager = PHCachingImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true

        DispatchQueue.global(qos: .userInteractive).async {
            manager.requestImage(for: assets.first ?? PHAsset(),
                                 targetSize: .init(),
                                 contentMode: .default,
                                 options: options) { image, _ in
                guard let image else { return }
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }

}

struct EditProfileView_Previews: PreviewProvider {
    @State static var userViewModel = UserViewModel()
    @State static var chattingViewModel = ChattingViewModel()
    static var previews: some View {
        EditProfileView()
            .environmentObject(userViewModel)
            .environmentObject(chattingViewModel)
            .onAppear {
                    userViewModel.currentUser = User(gmail: "lollotom0z@gmail.com", id: "", name: "Serhii")
                chattingViewModel.chats = [
                    Chat(),
                    Chat(),
                    Chat()
                ]
            }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension View {
    func placeholder(
        _ text: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading) -> some View {

        placeholder(when: shouldShow, alignment: alignment) { Text(text).foregroundColor(.gray) }
    }
}
