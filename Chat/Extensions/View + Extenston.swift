//
//  View + Extenston.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import Foundation
import SwiftUI

extension View {
    func addGradientBackground() -> some View {
        return self.background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(colors: [
                        Color("Gradient1"),
                        Color("Gradient2"),
                        Color("Gradient3")
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .ignoresSafeArea()
        }
    }
}

extension View {

    func toButtonLightStyle(size: CGFloat) -> some View {
        return self
            .foregroundColor(.gray)
            .frame(width: size, height: size)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5 )

    }

    func addLightShadow() -> some View {
        return self.shadow(color: .black.opacity(0.16), radius: 5, x: 5, y: 5)
    }
}

// Extension for adding rounded corners to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

// Custom RoundedCorner shape used for cornerRadius extension above
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func backgroundBlur(radius: CGFloat = 3, opaque: Bool = false) -> some View {
        self
            .background(
                Blur(radius: radius, opaque: opaque)
            )
    }

    func addBlackOverlay(loadExpandedContent: Bool,
                         imageOffsetProgress: CGFloat) -> some View {
        self
            .overlay(content: {
                Rectangle()
                    .fill(.black)
                    .opacity(loadExpandedContent ? 1 : 0)
                    .opacity(imageOffsetProgress)
                    .ignoresSafeArea()
            })
    }

    func addRightGestureRecognizer(swiped: @escaping () -> Void) -> some View {
        self
            .gesture(DragGesture(minimumDistance: 30)
                .onEnded({ value in
                    if value.translation.width > 30 {
                        swiped()
                    }
                })
            )
    }
}
