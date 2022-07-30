//
//  CustomAllert.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import Foundation
import SwiftUI

struct CustomAlert: View {

    @Binding var show: Bool
    @Binding var text: String

    @EnvironmentObject var viewModel: UserViewModel

    var body: some View {
        VStack {
            Text("Error")
                .font(.title)
                .fontWeight(.semibold)
                .padding()
                .foregroundColor(.white)
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .frame(alignment: .center)
                .padding()
                .padding(.horizontal, 10)
            Button {
                withAnimation {
                    show = false
                    viewModel.showAlert = false
                }
            } label: {
                Text("Close")
                    .padding()
                    .padding(.horizontal, 50)
                    .background(.white)
                    .cornerRadius(15)
            }
            .buttonStyle(.borderless)

        }
        .padding()
        .padding(.horizontal, 40)
        .background(.gray)
        .cornerRadius(15)

    }
}
