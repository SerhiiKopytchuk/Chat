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
    @EnvironmentObject var viewModel:AppViewModel
    let chat:Chat
    let rowTapped: () -> ()
    
    var body: some View {
        HStack{
            Image(systemName: "person")
                .padding(.trailing)
            VStack(alignment: .leading){
                HStack{
                    Text(viewModel.secondUser.name)
                    Spacer()
                    Text("12:34")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(viewModel.secondUser.gmail)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 40)
            .onTapGesture {
                rowTapped()
            }
    }
    


}
