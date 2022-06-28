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
    @State var description: String = ""
    @State var searchText: String = ""
    @State var usersToAddInChannel: [String] = []

    @State var imageUrl = URL(string: "")
    @State var isFindChannelImage = true
    @State var isAddedToChannel = false

    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel
    @ObservedObject var imageViewModel = ImageViewModel()

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack {
//            LinearGradient(gradient: Gradient(
//                colors: [.brown, .white, .white]),
//                           startPoint: .topLeading,
//                           endPoint: .bottomTrailing)
            Color("Gray")
            .ignoresSafeArea()

            ZStack(alignment: .top) {
                Color.white
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(x: 0, y: 50)
                VStack {
                    changeChannelImageView
                    TextField("Enter name of your channel", text: $name)
                        .underlineTextField()
                        .padding(.horizontal, 20)
                    TextField("Describe your channel", text: $description)
                        .underlineTextField()
                        .padding(.horizontal, 20)

                    HStack {
                        TextField("Search Users", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: searchText) { newText in
                                viewModel.searchText = newText
                                viewModel.getAllUsers()
                                // get all users with this name
                            }
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(width: 50, height: 50)
                    }
                    .padding(.horizontal, 20)

                    usersList
                    createChannelButton
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $channelImage)
        }
    }

    @ViewBuilder var usersList: some View {
        List {
            ForEach(viewModel.users, id: \.id) { user in
                AddUserCreateChannelRow(user: user.name,
                                        userGmail: user.gmail,
                                        id: user.id,
                                        addOrRemoveButtonTaped: { id in

                    if self.isAddedToChannel {
                        if let index = usersToAddInChannel.firstIndex(of: id) {
                            usersToAddInChannel.remove(at: index)
                        }
                    } else {
                        usersToAddInChannel.append(id)
                    }

                },
                                        isAddedToChannel: $isAddedToChannel)
                .onAppear {
                    if usersToAddInChannel.contains(user.id) {
                        isAddedToChannel = true
                    } else {
                        isAddedToChannel = false
                    }
                }
            }
        }
    }

    var emptyImage: some View {
        Image(systemName: "photo.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.black.opacity(0.70))
            .background(.white)
            .cornerRadius(50)
    }

    var changeChannelImageView: some View {
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
                }
            } else {
                emptyImage
            }

        }
        .frame(width: 100, height: 100)
    }

    var createChannelButton: some View {
        Button {
            channelViewModel.currentUser = viewModel.user
            channelViewModel.owner = viewModel.user
            channelViewModel.createChannel( subscribersId: usersToAddInChannel,
                                            name: self.name,
                                            description: self.description) { channel in
                imageViewModel.saveImage(image: self.channelImage ?? UIImage(),
                                         imageName: channel.id ?? "some Id")
            }
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Create channel")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(name.count < 4 ? .gray : .orange)
                .cornerRadius(10)
                .shadow(color: name.count < 4 ? .gray : .orange, radius: 3)
        }
        .disabled(name.count > 3 ? false : true)

    }
}

struct CreateChannelView_Previews: PreviewProvider {
    static var previews: some View {
        CreateChannelView()
            .environmentObject(ChannelViewModel())
            .environmentObject(AppViewModel())
    }
}
