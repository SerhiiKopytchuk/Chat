//
//  PinchZoomContext.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 09.11.2022.
//

import SwiftUI

extension View {
    func addPinchZoom() -> some View {
        return PinchZoomContext {
            self
        }
    }
}

struct PinchZoomContext<Content: View>: View {

    var content: Content

    @State var offset: CGPoint = .zero
    @State var scale: CGFloat = 0
    @State var scalePosition: CGPoint = .zero

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .offset(x: offset.x, y: offset.y )
            .overlay {
                GeometryReader { proxy in
                    let size = proxy.size

                    ZoomGesture(size: size, scale: $scale, offset: $offset, scalePosition: $scalePosition)
                }
            }
            .scaleEffect(1 + scale, anchor: .init(x: scalePosition.x, y: scalePosition.y))
    }
}

struct ZoomGesture: UIViewRepresentable {

    var size: CGSize

    @Binding var scale: CGFloat
    @Binding var offset: CGPoint

    @Binding var scalePosition: CGPoint

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        view.backgroundColor = .clear

        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator,
                                                    action: #selector(context.coordinator.handlePinch(sender:)))

        view.addGestureRecognizer(pinchGesture)

        let panGesture = UIPanGestureRecognizer(target: context.coordinator,
                                                    action: #selector(context.coordinator.handlePan(sender:)))

        panGesture.delegate = context.coordinator

        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {

        var parent: ZoomGesture

        init(parent: ZoomGesture) {
            self.parent = parent
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        @objc
        func handlePinch(sender: UIPinchGestureRecognizer) {
            if sender.state == .began || sender.state == .changed {
                parent.scale = sender.scale - 1

                let scalePoint = CGPoint(x: sender.location(in: sender.view).x / sender.view!.frame.size.width,
                                         y: sender.location(in: sender.view).y / sender.view!.frame.size.height)

                parent.scalePosition = (parent.scalePosition == .zero ? scalePoint : parent.scalePosition)
            } else {
                withAnimation(.easeInOut(duration: 0.35)) {
                    parent.scale = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.parent.scalePosition = .zero
                }
            }
        }

        @objc
        func handlePan(sender: UIPanGestureRecognizer) {

            sender.maximumNumberOfTouches = 2

            if (sender.state == .began || sender.state == .changed) && parent.scale > 0 {
                if let view = sender.view {
                    let translation = sender.translation(in: view )

                    parent.offset = translation
                }
            } else {
                withAnimation {
                    parent.offset = .zero
                    parent.scalePosition = .zero
                }
            }

        }
    }
}
