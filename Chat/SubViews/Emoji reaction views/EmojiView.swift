//
//  EmojiView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 05.08.2022.
//

import SwiftUI

struct EmojiView: View {
    // MARK: - vars
    @Binding var hideView: Bool
    var message: Message
    var onTap: (String) -> Void
    private let emojis: [String] = ["🔥", "❤️", "😁", "👍", "😍", "💩"]

    @State private var animateEmoji: [Bool] = Array(repeating: false, count: 6)
    @State var animateView: Bool = false

    // MARK: - body
    var body: some View {
        HStack(spacing: 12) {
            ForEach(emojis.indices, id: \.self) { index in
                Text(emojis[index])
                    .font(.system(size: 25))
                    .scaleEffect(animateEmoji[index] ? 1 : 0.01)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut.delay(Double(index) * 0.1)) {
                                animateEmoji[index] = true
                            }
                        }
                    }
                    .onTapGesture {
                        onTap(emojis[index])
                    }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(.white)
                .mask {
                    Capsule()
                        .scaleEffect()
                        .scaleEffect(animateView ? 1 : 0, anchor: .leading)
                }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                animateView = true
            }
        }
        .onChange(of: hideView) { newValue in
            if !newValue {
                withAnimation(.easeInOut(duration: 0.15)) {
                    animateView = false
                }
            }
            for index in emojis.indices {
                withAnimation(.easeInOut) {
                    animateEmoji[index] = false
                }
            }
        }
    }
}

struct EmojiView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiView(hideView: .constant(true), message: Message(), onTap: { _ in

        })
    }
}
