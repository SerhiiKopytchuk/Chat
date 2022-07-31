//
//  searchUserCell.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 05.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct SearchUserCell: View {
    var userName: String
    var userGmail: String
    var id: String
    var userColor: String
    let rowTapped: () -> Void
    let imageSize: CGFloat = 50

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    var body: some View {
            HStack {

                userImage

                VStack(alignment: .leading) {
                    Text(userName)
                        .font(.title)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Text(userGmail)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.white)
            }

            .onTapGesture {
                rowTapped()
            }
            .onAppear {
                let ref = Storage.storage().reference(withPath: self.id )
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

    @ViewBuilder var userImage: some View {
        if isFindUserImage {
            WebImage(url: imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(imageSize/2)
                .addLightShadow()
                .padding(.trailing)
        } else {
            if let first = userName.first {
                Text(String(first.uppercased()))
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .frame(width: imageSize, height: imageSize)
                    .background {
                        Circle()
                            .fill(Color(userColor))
                    }
                    .addLightShadow()
                    .padding(.trailing)
            }
        }
    }
}
