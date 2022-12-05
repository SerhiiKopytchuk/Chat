//
//  FullScreenImageCover.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 14.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct FullScreenImageCoverHeader: View {

    // MARK: - variables

    var name: String

    let animationHeaderImageNamespace: Namespace.ID

    @State var namespaceId: String

    @Binding var isExpandedHeaderImage: Bool

    @Binding var imageOffset: CGSize

    @State var headerImageURL: URL?

    @Binding var loadExpandedContent: Bool

    @EnvironmentObject private var channelViewModel: ChannelViewModel

    // MARK: - body
    var body: some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
                WebImage(url: headerImageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(loadExpandedContent ? 0 : size.height)
                    .offset(y: loadExpandedContent ? imageOffset.height : .zero)
                    .addPinchZoom()
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                    imageOffset = value.translation
                            }).onEnded({ value in
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
            .matchedGeometryEffect(id: namespaceId, in: animationHeaderImageNamespace)
            .frame(height: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top, content: {
            HStack(spacing: 10) {
                turnOffImageButton

                if isExpandedHeaderImage {
                    Text(name)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }

                Spacer(minLength: 10)
            }
            .padding()
            .opacity(loadExpandedContent ? 1 : 0)
            .opacity(imageOffsetProgress())
        })
        .transition(.offset(x: 0, y: 1))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                loadExpandedContent = true
            }
        }
    }

    // MARK: - viewBuilders

    @ViewBuilder private var turnOffImageButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                loadExpandedContent = false
            }
            withAnimation(.easeInOut(duration: 0.3).delay(0.05)) {
                isExpandedHeaderImage = false
            }

        } label: {
            Image(systemName: "arrow.left")
                .font(.title3)
                .foregroundColor(.white)
        }
    }

    // MARK: - functions

    private func imageOffsetProgress() -> CGFloat {
        let progress = imageOffset.height / 100
        if imageOffset.height < 0 {
            return 1
        } else {
            return 1  - (progress < 1 ? progress : 1)
        }
    }

    private func turnOffImageView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            loadExpandedContent = false
        }

        withAnimation(.easeInOut(duration: 0.3).delay(0.05)) {
            isExpandedHeaderImage = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            imageOffset = .zero
        }
    }

}
