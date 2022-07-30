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

    @Environment(\.self) var presentationMode

    var body: some View {
        VStack {
            header
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
                        if self.channelImage != nil {
                            Image(uiImage: self.channelImage ?? UIImage())
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageSize, height: imageSize)
                                .cornerRadius(imageSize/2)
                                .addLightShadow()
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
                    .padding(.vertical, 20)
                    .padding(.horizontal, 15)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white)
                    }
                    .padding()
            }

            TextField("Type channel description", text: $channelDescription)

                .padding(.vertical, 20)
                .padding(.horizontal, 15)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white)
                }
                .padding(.top, 15)
                .padding()

            Spacer()
        }
        .navigationBarHidden(true)
        .background {
            Color("BG")
                .ignoresSafeArea()
        }
        .onChange(of: channelImage ?? UIImage(), perform: { newImage in
            editChannelViewModel.saveImage(image: newImage)
        })
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $channelImage)
        }
    }

    @ViewBuilder var header: some View {
        HStack(spacing: 15) {
            Button {
                presentationMode.dismiss()
            } label: {
                Image(systemName: "arrow.backward.circle.fill")
                    .toButtonLightStyle(size: 40)
            }

            Text("Edit channel")
                .lineLimit(1)
                .font(.title.bold())
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                channelName = channelName.trim()
                channelDescription = channelDescription.trim()
                if channelName.isValidateLengthOfName() {
                    editChannelViewModel.updateChannelInfo(name: channelName, description: channelDescription)

                    channelViewModel.currentChannel = editChannelViewModel.currentChannel
                    channelViewModel.getChannels(fromUpdate: true)
                    presentationMode.dismiss()
                }
            } label: {
                Image(systemName: "checkmark")
                    .toButtonLightStyle(size: 40)
            }
            .frame(alignment: .trailing)
        }
        .padding(.horizontal)
    }

    @ViewBuilder var emptyImage: some View {
        Image(systemName: "photo.circle.fill")
            .resizable()
            .frame(width: 50, height: 50)
            .foregroundColor(.black.opacity(0.70))
            .background(.white)
            .cornerRadius(25)
            .addLightShadow()
    }
}

struct EditChannelView_Previews: PreviewProvider {
    static var previews: some View {
        EditChannelView(channelName: "Koch", channelDescription: "description")
    }
}
