//
//  CLTypingRubyLabel.swift
//  Dezitama_ver2
//
//  Created by 濱松未波 on 2025/07/08.
//
import SwiftUI
import UIKit

//ルビ付きの文字をタイピング風アニメーションで表示させるコード
class CLTypingRubyLabel: RubyLabel {
    var charInterval: Double = 0.05
    private var currentDispatchID = 0
    private var typingStopped = false
    private var typingOver = true
    private var stoppedSubstring: NSAttributedString?
    private let dispatchSerialQ = DispatchQueue(label: "CLTypingRubyQueue")

    override var attributedText: NSAttributedString! {
        get { super.attributedText }
        set {
            currentDispatchID += 1
            typingStopped = false
            typingOver = false
            stoppedSubstring = nil
            setAttributedTextWithTypingAnimation(newValue, charInterval, true, currentDispatchID)
        }
    }

    private func setAttributedTextWithTypingAnimation(_ fullText: NSAttributedString, _ interval: Double, _ initial: Bool, _ id: Int) {
        guard id == currentDispatchID else {
            typingOver = true
            return
        }

        if initial {
            super.attributedText = NSAttributedString(string: "")
        }

        if fullText.length == 0 {
            typingOver = true
            return
        }

        let firstChar = fullText.attributedSubstring(from: NSRange(location: 0, length: 1))
        let remaining = fullText.attributedSubstring(from: NSRange(location: 1, length: fullText.length - 1))

        DispatchQueue.main.async {
            let current = NSMutableAttributedString(attributedString: self.attributedText ?? NSAttributedString(string: ""))
            current.append(firstChar)
            super.attributedText = current

            self.dispatchSerialQ.asyncAfter(deadline: .now() + interval) {
                self.setAttributedTextWithTypingAnimation(remaining, interval, false, id)
            }
        }
    }
}


struct TypingRubyLabelRepresentable: UIViewRepresentable {
    let attributedText: NSAttributedString
    let charInterval: Double
    let font: UIFont

    func makeUIView(context: Context) -> CLTypingRubyLabel {
        let label = CLTypingRubyLabel()
        label.charInterval = charInterval
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = font
        return label
    }

    func updateUIView(_ uiView: CLTypingRubyLabel, context: Context) {
        uiView.font = font
        uiView.attributedText = attributedText
    }
}
