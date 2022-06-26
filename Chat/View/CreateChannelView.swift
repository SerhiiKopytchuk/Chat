//
//  CreateChannelView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 26.06.2022.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
import UIKit

struct CreateChannelView: View {

    @State var channelImage: UIImage?
    @State var isShowingImagePicker = false
    @State var name: String = ""

    @State var imageUrl = URL(string: "")
    @State var isFindChannelImage = true

    @EnvironmentObject var channelViewModel: ChannelViewModel

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(
                colors: [.brown, .white, .white]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()

            ZStack(alignment: .top) {
                Color.white
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(x: 0, y: 50)
                VStack {
                    changeProfileImageButton
                    HStack {
                        TextField("Enter name of your channel", text: $name)
                            .underlineTextField()
                            .padding(.leading, 20)

                    }

                }
            }
        }
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $channelImage)
        }
    }

    var emptyImage: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.black.opacity(0.70))
            .background(.white)
            .cornerRadius(50)

    }

    var changeProfileImageButton: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            if self.channelImage != nil {
                ZStack {
                    Image(uiImage: self.channelImage ?? UIImage())
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
        .frame(width: 100, height: 100)

        //    var saveButton: some View {
        //        Button {
        //        } label: {
        //            Text("save")
        //                .frame(width: 60)
        //                .padding(10)
        //                .foregroundColor(.white)
        //                .background(newName.count < 4 ? .gray : .orange)
        //                .cornerRadius(10)
        //                .shadow(color: newName.count < 4 ? .gray : .orange, radius: 3)
        //        }
        //        .disabled(newName.count > 3 ? false : true)
        //
        //    }
    }
}

struct CreateChannelView_Previews: PreviewProvider {
    static var previews: some View {
        CreateChannelView()
            .environmentObject(ChannelViewModel())
    }
}
