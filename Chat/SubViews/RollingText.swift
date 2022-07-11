//
//  RollingText.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 11.07.2022.
//

import SwiftUI

struct RollingText: View {
    // MARK: text properties
    var font: Font = .caption
    var weight: Font.Weight = .light

    // MARK: animation properties

    @State var animationRange: [Int] = []

    @Binding var value: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<animationRange.count, id: \.self) { index in
                // MARK: to find text size for given font
                Text("8")
                    .font(font)
                    .fontWeight(weight)
                    .opacity(0)
                    .overlay {
                        GeometryReader { proxy in
                            let size = proxy.size

                            VStack(spacing: 0) {
                                ForEach(0...9, id: \.self) { number in
                                    Text("\(number)")
                                        .font(font)
                                        .fontWeight(weight)
                                        .frame(width: size.width, height: size.height, alignment: .center)
                                }
                            }
                            .offset(y: -CGFloat(animationRange[index]) * size.height)
                            // MARK: setting offset
                        }
                        .clipped()
                    }
            }
        }
        .onAppear {
            animationRange = Array(repeating: 0, count: "\(value)".count)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                updateText()
            }
        }.onChange(of: value) { _ in
            let extra = "\(value)".count - animationRange.count
            if extra > 0 {
                for _ in 0..<extra {
                    withAnimation(.easeIn(duration: 0.1)) {
                        animationRange.append(0)
                    }
                }
            } else {
                for _ in 0..<(-extra) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        animationRange.removeLast()
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                updateText()
            }
        }
    }

    func updateText() {
        let stringValue = "\(value)"
        for (index, value) in zip(0..<stringValue.count, stringValue) {

            var fraction = Double(index) * 0.15
            fraction = (fraction > 0.5 ? 0.5 : fraction)
            withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 1, blendDuration: 1 + fraction)) {
                animationRange[index] = (String(value) as NSString).integerValue
            }
        }
    }
}
