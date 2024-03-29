//
//  ImageDetailedView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 23.12.2022.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct ImageDetailedView: View {

    // MARK: - Variables

    @State private var isAnimating: Bool = false
    @State private var imageScale: CGFloat = 1
    @State private var imageOffset: CGSize = .zero
    @State private var isDrawerOpen: Bool = false

    @State private var showShareButton: Bool = false

    let imagesURL: [URL?]
    @State private var images: [Image] = []

    @State var pageIndex: Int

    @Binding var isPresented: Bool

    var screenWidth: CGFloat {
        return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }

    var screenHeight: CGFloat {
        return max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }

    // MARK: - body
    var body: some View {
        ZStack {

            Color.clear

            imageView
        }
        .onAppear {
            withAnimation(.linear(duration: 1)) {
                isAnimating = true
            }

            fetchImages()
        }
        .overlay(alignment: .top) {
            HStack {
                backButton

                Spacer()

                shareImage()

            }
        }
        .overlay(alignment: .bottom) {
            controlCenter
        }
        .overlay(alignment: .topTrailing) {
            pageSelector
        }
        .background(Color.background)
    }

    // MARK: - ViewBuilders

    @ViewBuilder private func shareImage() -> some View {
        if showShareButton {
            let image = ImageFile(image: images[pageIndex])
            let imageName = "ChatImage_\(getCurrentDateDescription())"
            ShareLink(item: image, preview: SharePreview(imageName, image: image.image)) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .padding(.horizontal)
                    .padding(.top, 30)
            }
        }
    }

    @ViewBuilder private var imageView: some View {
        WebImage(url: imagesURL[pageIndex])
            .resizable()
            .scaledToFit()
            .cornerRadius(10)
            .padding()
            .shadow(color: .black.opacity(0.2), radius: 12, x: 2, y: 2)
            .opacity(isAnimating ? 1 : 0)
            .offset(imageOffset)
            .scaleEffect(imageScale)
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

    @ViewBuilder private var backButton: some View {
        Button {
            withAnimation(.easeOut(duration: 0.3).delay(0.05)) {
                isPresented = false
            }
        } label: {
            Image(systemName: "arrow.left")
                .font(.title3)
                .padding(.horizontal)
                .padding(.top, 30)
        }
    }

    @ViewBuilder private var controlCenter: some View {
        Group {
            HStack {

                Button {
                    minusScale()
                } label: {
                    ControlImageView(icon: "minus.magnifyingglass")
                }

                Button {
                    resetImageState()
                } label: {
                    ControlImageView(icon: "arrow.up.left.and.down.right.magnifyingglass")
                }

                Button {
                    plusScale()
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

    @ViewBuilder private var pageSelector: some View {
        if imagesURL.count > 1 {
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
    }

    // MARK: - functions

    private func minusScale() {
        withAnimation(.spring()) {
            if imageScale > 1 {
                imageScale -= 1

                if imageScale <= 1 {
                    resetImageState()
                }
            }
        }
    }

    private func resetImageState() {
        return withAnimation(.spring()) {
            imageScale = 1
            imageOffset = .zero
            print(UIScreen.main.bounds)
        }
    }

    private func plusScale() {
        withAnimation(.spring()) {
            if imageScale < 5 {
                imageScale += 1

                if imageScale > 5 {
                    imageScale = 5
                }
            }
        }
    }

    private func fetchImages() {
        let fetchImagesGroup = DispatchGroup()

        for url in imagesURL {
            DispatchQueue.global(qos: .utility).async(group: fetchImagesGroup) {
                fetchImagesGroup.enter()

                SDWebImageManager.shared.loadImage(with: url,
                                                   options: .highPriority,
                                                   progress: nil) { image, _, _, _, finished, _ in

                    self.images.append(Image(uiImage: image ?? UIImage()))

                    if finished {
                        fetchImagesGroup.leave()
                    }
                }

            }
        }

        fetchImagesGroup.notify(queue: .main) {
            showShareButton = true
        }
    }

    private func getCurrentDateDescription() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}

struct ImageFile: Transferable {
    var image: Image
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
}
