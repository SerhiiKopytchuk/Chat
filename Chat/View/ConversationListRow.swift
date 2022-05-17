//
//  ConversationListRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 17.05.2022.
//
import Foundation
import SwiftUI

struct ConversationListRow: View {
    // Inject properties into the struct
    let name: String
    let textMessage:String
    let time:String
    
    let rowTapped: () -> ()

    var body: some View {
        HStack{
            Image(systemName: "person")
                .padding(.trailing)
            VStack(alignment: .leading){
                HStack{
                    Text(name)
                    Spacer()
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(textMessage)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 40)
            .onTapGesture {
                rowTapped()
            }
    }
}

struct ConversationListRow_Previews: PreviewProvider {
    static var previews: some View {
        ConversationListRow(name: "Serhii", textMessage: "some message", time: "12:45", rowTapped: { print("tapped") })
    }
}
