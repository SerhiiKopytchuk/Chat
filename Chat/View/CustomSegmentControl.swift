//
//  CustomSegmentControl.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 04.09.2022.
//

import SwiftUI

struct CustomSegmentControl: View {

    @Binding var selection: Int

    var body: some View {
        VStack(spacing: 1) {

            Divider()
                .background(.white.opacity(0.5))
                .blendMode(.overlay)
                .shadow(color: .black.opacity(0.2), radius: 0, x: 0, y: 1)
                .blendMode(.overlay)
                .overlay {
                    HStack {
                        Divider()
                            .frame(width: UIScreen.main.bounds.width / 2, height: 3)
                            .background(Color.underline)
                            .blendMode(.overlay)
                    }
                    .frame(maxWidth: .infinity, alignment: selection == 0 ? .leading : .trailing)
                    .offset(y: 1)
                }

            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        selection = 0
                    }
                } label: {
                    Image(systemName: "character.bubble")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 30)
                        .frame(maxWidth: .infinity )
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                Button {
                    withAnimation(.easeInOut) {
                        selection = 1
                    }
                } label: {
                    Image(systemName: "fibrechannel")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 30)
                        .frame(maxWidth: .infinity )
                }
                .frame(minWidth: 0, maxWidth: .infinity)

            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.secondary)
            .padding(.top, 10)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
}

struct CustomSegmentControl_Previews: PreviewProvider {
    static var previews: some View {
        CustomSegmentControl(selection: .constant(0))
    }
}
