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
    var title: String = "Error"
    var text: String

    @EnvironmentObject private var viewModel: UserViewModel
    // MARK: - body
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top)

            Text(text)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .frame(alignment: .center)
                .padding()

            closeButton

        }
        .padding()
        .padding(.horizontal, 30)
        .background(Color.background)
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
                .background(Color.secondPrimary)
                .cornerRadius(15)
        }
        .buttonStyle(.borderless)
    }
}
