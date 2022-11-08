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

    @State var messageImageURL: URL?

    @Binding var loadExpandedContent: Bool

    @State private var scale = 1.0
//    @State private var imageDragOffset: CGSize

    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { size in
                scale = size
            }
            .onEnded { _ in
                withAnimation {
                    scale = 1
                }
            }
    }
//
//    var dragGestureSecond: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                imageDragOffset = value
//            }
//            .onEnded { _ in
//                withAnimation {
//
//                }
//            }
//    }

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
                    .offset(x: loadExpandedContent ? imageOffset.width : .zero)
                    .scaleEffect(scale)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                imageOffset.height = value.translation.height
                                imageOffset.width = value.translation.width
                            })
                            .onEnded({ _ in
                                withAnimation(.interactiveSpring(response: 0.65,
                                                                 dampingFraction: 0.7,
                                                                 blendDuration: 0.3)) {
                                    imageOffset = .zero
                                }
                            })
                    )
                    .gesture(magnification)
            }
            .matchedGeometryEffect(id: namespaceId, in: animationMessageImageNamespace)
            .frame(height: 300)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top, content: {
            HStack(spacing: 10) {
                turnOffImageButton

                Spacer(minLength: 10)
            }
            .padding()
            .opacity(loadExpandedContent ? 1 : 0)
            .opacity(scale == 1.0 ? 1 : 0)
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
