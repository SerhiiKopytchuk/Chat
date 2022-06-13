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

    @State var image: UIImage?
    @State var isShowingImagePicker = false

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true
    @State var isChangedImage = false

    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        ZStack {
            VStack {
                Button {
                    isShowingImagePicker.toggle()
                } label: {
                    if isFindUserImage {
                        if self.image != nil {
                            Image(uiImage: self.image ?? UIImage())
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(.black, lineWidth: 3)
                                        .shadow(radius: 10)
                                )
                        } else {
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
                        }
                    } else {
                        if self.image != nil {
                            Image(uiImage: self.image ?? UIImage())
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(.black, lineWidth: 3)
                                        .shadow(radius: 10)
                                )
                        } else {
                            ZStack {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                                VStack(alignment: .trailing) {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image(systemName: "photo.circle")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .background(.gray)
                                            .foregroundColor(.white)
                                            .cornerRadius(30)
                                    }
                                }
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
        }
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(AppViewModel())
    }
}
