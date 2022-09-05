//
//  CustomTabBar.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.05.2022.
//

import SwiftUI

struct CustomTabBar: View {

    @Binding var selected: Int

    @State var yOfset: CGFloat = 0
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {

                barButton(selection: 0)
                barButton(selection: 1)

            }
            .frame(maxWidth: .infinity)
            .background(alignment: .leading) {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 20, height: 20)
                    .offset(x: 70, y: -yOfset )
                    .offset(x: indicatorOffset(width: width))
            }
        }
        .frame(height: 30)
        .padding(.bottom, 10)
        .padding([.horizontal, .top])
    }

    func barButton(selection: Int)-> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.selected = selection
                yOfset = 60
            }
            withAnimation(.easeInOut(duration: 0.1).delay(0.1)) {
                yOfset = 0
            }

        } label: {
            Image(systemName: "character.bubble")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 30)
                .frame(maxWidth: .infinity )
                .foregroundColor(selection == selected ? Color.purple : .gray)
                .scaleEffect(selection == selected && yOfset != 0 ? 1.5 : 1)
        }
    }

    func indicatorOffset(width: CGFloat) -> CGFloat {
        let index = CGFloat(selected)
        if index == 0 {return 0}

        let buttonWidth = width / CGFloat(Tab.allCases.count)

        return index * buttonWidth
    }
}
