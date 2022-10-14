//
//  FullScreenImageCover.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 14.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct FullScreenImageCoverMessage: View {

    // MARK: - variables

    let animationMessageImageNamespace: Namespace.ID

    @State var namespaceId: String

    @Binding var isExpandedImage: Bool
    @Binding var isExpandedImageWithDelay: Bool

    @Binding var imageOffset: CGSize

    @Binding var messageImageURL: URL?

    @Binding var loadExpandedContent: Bool

    // MARK: - body
    var body: some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
                WebImage(url: messageImageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(loadExpandedContent ? 0 : 15)
                    .offset(y: loadExpandedContent ? imageOffset.height : .zero)
                    .gesture(
                        DragGesture()
                            .onEnded({ value in
                                let height = value.translation.height
                                if height > 0 && height > 100 {
                                    turnOffImageView()
                                } else {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        imageOffset = .zero
                                    }
                                }
                            })
                    )
            }
            .matchedGeometryEffect(id: namespaceId, in: animationMessageImageNamespace)
            .frame(height: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top, content: {
            HStack(spacing: 10) {
                turnOffImageButton

                Spacer(minLength: 10)
            }
            .padding()
            .opacity(loadExpandedContent ? 1 : 0)
        })
        .transition(.offset(x: 0, y: 1))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                loadExpandedContent = true
            }
        }
    }

    // MARK: - ViewBuilders

    @ViewBuilder private var turnOffImageButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                loadExpandedContent = false
            }

            withAnimation(.easeInOut(duration: 0.3).delay(0.05)) {
                isExpandedImage = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut) {
                    isExpandedImageWithDelay = false

                }
            }

        } label: {
            Image(systemName: "arrow.left")
                .font(.title3)
                .foregroundColor(.white)
        }
    }

    // MARK: - functions
    private func turnOffImageView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            loadExpandedContent = false
        }

        withAnimation(.easeInOut(duration: 0.3).delay(0.05)) {
            isExpandedImage = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut) {
                isExpandedImageWithDelay = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            imageOffset = .zero
        }
    }
}
