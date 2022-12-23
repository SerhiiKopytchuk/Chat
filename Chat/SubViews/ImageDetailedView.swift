//
//  ImageDetailedView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 23.12.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageDetailedView: View {

    // MARK: - Variables

    @State private var isAnimating: Bool = false
    @State private var imageScale: CGFloat = 1
    @State private var imageOffset: CGSize = .zero
    @State private var isDrawerOpen: Bool = false
    let animationNamespace: Namespace.ID

    let imagesURL: [URL?]
    @State var pageIndex: Int
    let imagesID: [String]

    @Binding var isPresented: Bool
    @Binding var isExpandedImageWithDelay: Bool

    // MARK: - body
    var body: some View {
        ZStack {

            Color.clear

            WebImage(url: imagesURL[pageIndex])
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .padding()
                .shadow(color: .black.opacity(0.2), radius: 12, x: 2, y: 2)
                .opacity(isAnimating ? 1 : 0)
                .offset(imageOffset)
                .scaleEffect(imageScale)
                .matchedGeometryEffect(id: imagesID[0],
                                       in: animationNamespace)
                .onTapGesture(count: 2) {
                    if imageScale == 1 {
                        withAnimation(.spring()) {
                            imageScale = 5
                        }
                    } else {
                        resetImageState()
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            withAnimation(.linear(duration: 1)) {
                                imageOffset = value.translation
                            }
                        })
                        .onEnded({ _ in
                            if imageScale <= 1 {
                                resetImageState()
                            }
                        })
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged({ value in
                            withAnimation(.linear) {
                                if imageScale >= 1 && imageScale <= 5 {
                                    imageScale = value
                                } else if imageScale > 5 {
                                    imageScale = 5
                                }
                            }
                        })
                        .onEnded({ _ in
                            if imageScale > 5 {
                                imageScale = 5
                            } else if imageScale <= 1 {
                                resetImageState()
                            }
                        })
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 1)) {
                isAnimating = true
            }
        }
        .overlay(alignment: .topLeading) {

            Button {
                withAnimation(.easeOut(duration: 0.3).delay(0.05)) {
                    isPresented = false
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isExpandedImageWithDelay = false
                    }
                }
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title3)
                    .padding(.horizontal)
                    .padding(.top, 30)
            }

            InfoPanelView(scale: imageScale, offset: imageOffset)
                .padding(.horizontal)
                .padding(.top, 30)
        }
        .overlay(alignment: .bottom) {
            Group {
                HStack {
                    Button {
                        withAnimation(.spring()) {
                            if imageScale > 1 {
                                imageScale -= 1

                                if imageScale <= 1 {
                                    resetImageState()
                                }
                            }
                        }
                    } label: {
                        ControlImageView(icon: "minus.magnifyingglass")
                    }

                    Button {
                        resetImageState()
                    } label: {
                        ControlImageView(icon: "arrow.up.left.and.down.right.magnifyingglass")
                    }

                    Button {
                        withAnimation(.spring()) {
                            if imageScale < 5 {
                                imageScale += 1

                                if imageScale > 5 {
                                    imageScale = 5
                                }
                            }
                        }
                    } label: {
                        ControlImageView(icon: "plus.magnifyingglass")
                    }

                }
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .opacity(isAnimating ? 1 : 0)
            }
            .padding(.bottom, 30)
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 20) {
                Image(systemName: isDrawerOpen ? "chevron.compact.right" : "chevron.compact.left")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .padding(8)
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        withAnimation(.easeOut) {
                            isDrawerOpen.toggle()
                        }
                    }

                ForEach(imagesURL, id: \.self) { imageURL in
                    WebImage(url: imageURL)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .opacity(isDrawerOpen ? 1 : 0)
                        .animation(.easeOut(duration: 0.5), value: isDrawerOpen)
                        .onTapGesture {
                            isAnimating = true
                            self.pageIndex = imagesURL.firstIndex(of: imageURL) ?? 0
                        }
                }

                Spacer()
            }
            .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .opacity(isAnimating ? 1 : 0)
            .frame(width: 260)
            .padding(.top, UIScreen.main.bounds.height / 12)
            .offset(x: isDrawerOpen ? 20 : 215)
        }
        .background(Color.background)
        .offset(y: 0.01)
    }

    // MARK: - ViewBuilders

    // MARK: - functions

    func resetImageState() {
        return withAnimation(.spring()) {
            imageScale = 1
            imageOffset = .zero
        }
    }
}
