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
    var user: String
    var userGmail: String
    var id: String
    let rowTapped: () -> Void

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    var body: some View {

            HStack {
                if isFindUserImage {
                    WebImage(url: imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .cornerRadius(20)
                        .padding()
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                VStack(alignment: .leading) {
                    Text(user)
                        .font(.title)
                    Text(userGmail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
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
}

struct SearchUserCell_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserCell( user: "Georgy", userGmail: "georgy@gmail.com", id: "someId", rowTapped: { })
    }
}
