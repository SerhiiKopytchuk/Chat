//
//  searchUserCell.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 05.06.2022.
//

import SwiftUI

struct SearchUserCell: View {
    var user: String
    var userGmail: String
    let rowTapped: () -> Void
    var body: some View {

            HStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding()
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
    }
}

struct SearchUserCell_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserCell( user: "Georgy", userGmail: "georgy@gmail.com", rowTapped: { })
    }
}
