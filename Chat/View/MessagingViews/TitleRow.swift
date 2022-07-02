//
//  TitleRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct TitleRow: View {
    var user: User
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    var body: some View {
        HStack(spacing: 20) {
            if isFindUserImage {
                WebImage(url: imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(50)
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
            }

            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.title).bold()

                Text("Online")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "xmark")
                .foregroundColor(.gray)
                .padding(10)
                .background(.white)
                .cornerRadius(40 )
                .onTapGesture {
                    chattingViewModel.deleteChat()
                    chattingViewModel.getChats(fromUpdate: true)
                    presentationMode.wrappedValue.dismiss()
                }
        }
        .padding()
        .onAppear {
            let ref = Storage.storage().reference(withPath: user.id )
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

struct TitleRow_Previews: PreviewProvider {
    static var previews: some View {
        TitleRow(user: User(chats: [], channels: [], gmail: "", id: "", name: ""))
            .background(Color("Peach"))
    }
}
