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
    @State var channelColor: String

    @State var channelImage: UIImage?
    @State var isShowingImagePicker = false
    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true
    @State var isChangedImage = false

    @State var isShowAlert = false

    @EnvironmentObject var editChannelViewModel: EditChannelViewModel
    @EnvironmentObject var channelViewModel: ChannelViewModel

    var imageSize: CGFloat = 50

    @Environment(\.self) var presentationMode

    var body: some View {
        VStack {
            header
            HStack {
                imageButton

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
        .overlay {
            customAlert
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
                } else {
                    isShowAlert = true
                }
            } label: {
                Image(systemName: "checkmark")
                    .toButtonLightStyle(size: 40)
            }
            .frame(alignment: .trailing)
        }
        .padding(.horizontal)
    }

    @ViewBuilder var imageButton: some View {
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
                    EmptyImageWithCharacterView(text: channelName, colour: channelColor, size: imageSize)
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
    }

    @ViewBuilder var customAlert: some View {
        if isShowAlert {
            GeometryReader { geometry in
                CustomAlert(show: $isShowAlert, text: channelName.count > 3 ?
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

struct EditChannelView_Previews: PreviewProvider {
    static var previews: some View {
        EditChannelView(channelName: "Koch",
                        channelDescription: "description",
                        channelColor: String.getRandomColorFromAssets())
    }
}
