//
//  AnimatedEmoji.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 05.08.2022.
//

import SwiftUI

struct AnimatedEmoji: View {

    // MARK: - variables
    var emoji: String
    var color: Color = .blue

    @State private var animationValues: [Bool] = Array(repeating: false, count: 6)

    // MARK: - body
    var body: some View {
        ZStack {

            Text(emoji)
                .font(.system(size: 25))
                .padding(6)
                .background {
                    Circle()
                        .fill(color)
                }
                .scaleEffect(animationValues[2] ? 1 : 0)
                .overlay {
                    Circle()
                        .stroke(color, lineWidth: animationValues[1] ? 0 : 100)
                        .clipShape(Circle())
                        .scaleEffect(animationValues[0] ? 1.6 : 0.01)
                }
                .overlay {
                    ZStack {
                        ForEach(1...20, id: \.self) { index in
                            Circle()
                                .fill(color)
                                .frame(width: .random(in: 3...5), height: .random(in: 3...5))
                                .offset(x: .random(in: -5...5), y: .random(in: -5...5))
                                .offset(x: animationValues[3] ? 45 : 10)
                                .rotationEffect(.init(degrees: Double(index) * 18))
                                .scaleEffect(animationValues[2] ? 1 : 0.01)
                                .opacity(animationValues[4] ? 0 : 1)
                        }
                    }
                }
        }
        .onAppear {
            animate()
        }
    }

    // MARK: - functions
    private func animate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.35)) {
                animationValues[0] = true
            }
            withAnimation(.easeInOut(duration: 0.45).delay(0.06)) {
                animationValues[1] = true
            }
            withAnimation(.easeInOut(duration: 0.35).delay(0.3)) {
                animationValues[2] = true
            }
            withAnimation(.easeInOut(duration: 0.35).delay(0.3)) {
                animationValues[3] = true
            }
            withAnimation(.easeInOut(duration: 0.55).delay(0.55)) {
                animationValues[4] = true
            }
        }
    }

}

struct AnimatedEmoji_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedEmoji(emoji: "❤️")
    }
}
