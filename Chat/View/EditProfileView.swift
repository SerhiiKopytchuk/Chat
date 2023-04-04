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

    // MARK: image properties
    @State private var imageUrl = URL(string: "")
    @State private var isFindUserImage = true
    private let imageSize: CGFloat = 100

    @State private var alertText: String?
    @State private var alertType: AlertType = .success

    @State private var showDeleteAccountAlert = false

    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var chattingViewModel: ChattingViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel
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
        VStack {
            HeaderWithBackButton(environment: _env, text: "profile")

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
                    .frame(maxWidth: .infinity)

                    Spacer()

                    Divider()
                        .overlay(Color.secondPrimary)

                    TextFieldWithBorders(iconName: "person",
                                         placeholderText: "Enter your new name",
                                         text: $newName)
                    .padding()

                    Spacer()

                    saveButton

                    deleteAccountButton
                }

            }
            .frame(height: screenSize.height/2.5)
        }
        .background {
            Color.background
                .ignoresSafeArea()
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
        .alert("Everything will be erased. Are you sure?", isPresented: $showDeleteAccountAlert) {
            Button("Delete", role: .destructive) {
                let group = DispatchGroup()
                    chattingViewModel.deleteEveryChat {}

                    channelViewModel.deleteEveryChannel()

                    group.enter()
                    userViewModel.deleteCurrentUser {
                        group.leave()
                    }

                    group.notify(queue: .main) {
                        userViewModel.signedIn = false
                        env.dismiss()
                    }
            }.foregroundColor(.red)
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - ViewBuilders

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
                        Image(uiImage: self.profileImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(imageSize/2)
                            .addLightShadow()
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

    @ViewBuilder private var saveButton: some View {
        Button {

            if !newName.isValidateLengthOfName() {
                alertType = .failure
                withAnimation {
                    alertText = newName.count > 3 ?
                                    "Name should be shorter than 35 symbols" :
                                    "Name should be longer than 3 symbols"
                }
                return
            }

            newName = newName.trim()
            if newName.count > 3 {
                editProfileViewModel.changeName(newName: newName, userId: userViewModel.currentUser.id )
                alertType = .success
                withAnimation {
                    alertText = "Name was changed successfully"
                }
            }
        } label: {
            Text("Save")
                .font(.title3)
                .fontWeight(.light)
                .foregroundColor(Color.green)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 15)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.green, lineWidth: 1)
                }
                .padding(.horizontal)
                .opacity(newName.isValidateLengthOfName() && newName != userViewModel.currentUser.name ? 1 : 0.6)
        }
        .padding(.bottom)
    }

    @ViewBuilder private var deleteAccountButton: some View {
        Button {
            withAnimation {
                showDeleteAccountAlert.toggle()
            }
        } label: {
            Text("Delete Account")
                .font(.title3)
                .fontWeight(.light)
                .foregroundColor(Color.red)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 15)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.red, lineWidth: 1)
                }
                .padding(.horizontal)
        }
            .padding(.bottom)
    }

    @ViewBuilder private var customAlert: some View {
        if alertText != nil {
            CustomAlert(text: $alertText, type: alertType)
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
