//
//  View + Extenston.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import Foundation
import SwiftUI

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
                    .ignoresSafeArea()
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

    func addBlackOverlay(loadExpandedContent: Bool) -> some View {
        self
            .overlay(content: {
                Rectangle()
                    .fill(.black)
                    .opacity(loadExpandedContent ? 1 : 0)
                    .ignoresSafeArea()
            })
    }

    func addRightGestureRecognizer(swiped: @escaping () -> Void) -> some View {
        self
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 30)
                .onEnded({ value in
                    if value.translation.width > 30 {
                        swiped()
                    }
                })
            )
    }

    @ViewBuilder func offsetX(completion: @escaping (CGRect) -> Void) -> some View {
        self
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)

                    Color.clear
                        .preference(key: OffsetKey.self, value: rect)
                        .onPreferenceChange(OffsetKey.self, perform: completion)
                }
            }
    }

    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }

    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }

    func placeholder(
        _ text: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading) -> some View {

        placeholder(when: shouldShow, alignment: alignment) { Text(text).foregroundColor(.gray) }
    }

    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }

        return root
    }
}
