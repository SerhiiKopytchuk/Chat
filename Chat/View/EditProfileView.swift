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

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true
    @State var isChangedImage = false

    @EnvironmentObject var viewModel: AppViewModel
    @ObservedObject var imageViewModel = ImageViewModel()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(
                colors: [.purple, .white, .white]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()

            ZStack {
                Color.white
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(x: 0, y: 100)
                VStack {
                     changeProfileImageButton
                }
            }
        }
        .onChange(of: profileImage ?? UIImage(), perform: { newImage in
            imageViewModel.saveImage(image: newImage)
        })
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $profileImage)
        }
    }

    var emptyImage: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.black.opacity(0.70))
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(.black, lineWidth: 3)
                                    .shadow(radius: 10)
                            )
//                                    rightDownImage
                    }
                } else {
                    ZStack {
                        WebImage(url: imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(.black, lineWidth: 3)
                                    .shadow(radius: 10)
                            )
//                                    rightDownImage
                    }
                }
            } else {
                if self.profileImage != nil {
                    ZStack {
                        Image(uiImage: self.profileImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(.black, lineWidth: 3)
                                    .shadow(radius: 10)
                            )
//                                    rightDownImage
                    }
                } else {
                    ZStack {
                        emptyImage
//                                    rightDownImage
                    }
                }
            }
        }
        .frame(width: 100, height: 100)
        .onAppear {
            let ref = Storage.storage().reference(withPath: viewModel.user.id )
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

//    var rightDownImage: some View {
//        VStack(alignment: .trailing) {
//            Spacer()
//            HStack {
//                Spacer()
//                Image(systemName: "photo.circle")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//                    .background(.white.opacity(0))
//                    .foregroundColor(.black.opacity(70))
//                    .cornerRadius(30)
//            }
//        }
//    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(AppViewModel())
    }
}
