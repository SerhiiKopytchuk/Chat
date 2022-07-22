//
//  EditChannelView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 22.07.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage

struct EditChannelView: View {

    @State var channelName: String
    @State var channelDescription: String

    @State var channelImage: UIImage?
    @State var isShowingImagePicker = false
    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true
    @State var isChangedImage = false

    @EnvironmentObject var editChannelViewModel: EditChannelViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel

    var imageSize: CGFloat = 50

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            HStack {
                Button {
                    isShowingImagePicker.toggle()
                } label: {
                    if isFindUserImage {
                        if self.channelImage != nil {
                            ZStack {
                                Image(uiImage: self.channelImage ?? UIImage())
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imageSize, height: imageSize)
                                    .cornerRadius(imageSize/2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CGFloat(imageSize/2))
                                            .stroke(.black, lineWidth: 3)
                                            .shadow(radius: 10)
                                    )
                            }
                        } else {
                            ZStack {
                                WebImage(url: imageUrl)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imageSize, height: imageSize)
                                    .cornerRadius(imageSize/2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: imageSize/2)
                                            .stroke(.black, lineWidth: 3)
                                            .shadow(radius: 10)
                                    )
                            }
                        }
                    } else {
                        if self.channelImage != nil {
                            Image(uiImage: self.channelImage ?? UIImage())
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageSize, height: imageSize)
                                .cornerRadius(imageSize/2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CGFloat(imageSize/2))
                                        .stroke(.black, lineWidth: 3)
                                        .shadow(radius: 10)
                                )
                        } else {
                            emptyImage
                        }
                    }
                }
                .padding()
                .onAppear {
                    let ref = Storage.storage().reference(withPath: channelViewModel.currentChannel.id ?? "someId" )
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
                TextField("Enter channel name", text: $channelName)
                        .textFieldStyle(.roundedBorder)
                        .padding()
        }

            TextField("Type channel description", text: $channelDescription)
                .textFieldStyle(.automatic)
                .padding()

            Spacer()
        }
        .onChange(of: channelImage ?? UIImage(), perform: { newImage in
            editChannelViewModel.saveImage(image: newImage)
        })
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $channelImage)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    channelName = channelName.trim()
                    channelDescription = channelDescription.trim()
                    editChannelViewModel.updateChannelInfo(name: channelName, description: channelDescription)

                    channelViewModel.currentChannel = editChannelViewModel.currentChannel
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .padding()
                }
            }
        }
    }
        @ViewBuilder var emptyImage: some View {

                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black.opacity(0.70))
                    .background(.white)
                    .cornerRadius(25)

        }
}

struct EditChannelView_Previews: PreviewProvider {
    static var previews: some View {
        EditChannelView(channelName: "Koch", channelDescription: "description")
    }
}
