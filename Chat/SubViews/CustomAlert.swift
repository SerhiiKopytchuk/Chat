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
        GeometryReader { geometry in
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
            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
            .frame(maxWidth: geometry.frame(in: .local).width - 20)
        }
        .background(Color.black.opacity(0.65))
        .edgesIgnoringSafeArea(.all)

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
