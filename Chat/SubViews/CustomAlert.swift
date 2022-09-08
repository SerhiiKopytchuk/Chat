//
//  CustomAllert.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import Foundation
import SwiftUI

struct CustomAlert: View {
    // MARK: - vars
    @Binding var show: Bool

    var text: String

    @EnvironmentObject private var viewModel: UserViewModel
    // MARK: - body
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

            closeButton

        }
        .padding()
        .padding(.horizontal, 30)
        .background(.gray)
        .cornerRadius(15)

    }

    // MARK: - ViewBuilders
    @ViewBuilder private var closeButton: some View {
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
}
