//
//  ResizeableTextView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.08.2022.
//

import SwiftUI

struct ResizeableTextView: UIViewRepresentable {

    @Binding var text: String
    @Binding var height: CGFloat
    var placeholderText: String
    @State var editing: Bool = false

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.text = placeholderText
        textView.textColor = .black
        textView.delegate = context.coordinator
        textView.backgroundColor = UIColor.clear

        textView.font = .systemFont(ofSize: 18)

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if self.text.isEmpty == true {
            textView.text = self.editing ? "" : self.placeholderText
            textView.textColor = self.editing ? .black : .lightGray
        } else {
            textView.textColor = UIColor(Color.primary)
        }

        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.height = textView.contentSize.height
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        ResizeableTextView.Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ResizeableTextView
        let textSizeLimit = 800

        init(_ params: ResizeableTextView) {
            self.parent = params
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
               self.parent.editing = true
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
               self.parent.editing = false
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                let oldText = self.parent.text

                withAnimation(.easeInOut(duration: 0.1)) {
                    if textView.text.count < self.textSizeLimit {
                        self.parent.height = textView.contentSize.height
                        self.parent.text = textView.text
                    } else if self.parent.text.dropLast() == textView.text {
                        self.parent.height = textView.contentSize.height
                        self.parent.text = textView.text
                    } else {
                        self.parent.height = textView.contentSize.height
                        self.parent.text = oldText
                        textView.text = oldText
                    }
                }
            }
        }

    }

}
