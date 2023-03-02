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
    @Binding var isShow: Bool
    var title: String = "Error"
    var text: String

    

    @EnvironmentObject private var viewModel: UserViewModel
    // MARK: - body
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(Color.redAlert)
                    .padding(.horizontal)

                Text(text)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(10)

                closeButton

            }
            .padding(30)
            .padding(.horizontal, 30)
            .background(Color.background)
            .cornerRadius(15)
            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
        }
        .padding(.horizontal, 30)
        .background(content: {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShow = false
                        viewModel.showAlert = false
                    }
                }
        })
        .edgesIgnoringSafeArea(.vertical)

    }

    // MARK: - ViewBuilders
    @ViewBuilder private var closeButton: some View {
        Button {
            withAnimation {
                isShow = false
                viewModel.showAlert = false
            }
        } label: {
            Text("Close")
                .padding()
                .padding(.horizontal, 30)
                .background(Color.secondPrimary.opacity(0.85))
                .cornerRadius(15)
        }
        .buttonStyle(.borderless)
    }
}
