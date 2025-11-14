//
//  CLTypingRubyLabel.swift
//  Dezitama_ver2
//
//  Created by 濱松未波 on 2025/07/08.
//
import SwiftUI
import UIKit

//ルビ付きの文字をタイピング風アニメーションで表示させるコード
class CLTypingRubyLabel: WideRubyLabel {
    var charInterval: Double = 0.05
    private var currentDispatchID = 0
    private var typingStopped = false
    private var typingOver = true
    private var stoppedSubstring: NSAttributedString?
    private let dispatchSerialQ = DispatchQueue(label: "CLTypingRubyQueue")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }

    private func setupLabel() {
        self.textAlignment = .left
        self.numberOfLines = 0
    }

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

        if fullText.length == 0 {
            typingOver = true
            return
        }


        let firstCharRange = NSRange(location: 0, length: 1)
        let firstChar = fullText.attributedSubstring(from: firstCharRange)
        let remainingRange = NSRange(location: 1, length: fullText.length - 1)
        let remaining = fullText.length > 1 ? fullText.attributedSubstring(from: remainingRange) : NSAttributedString(string: "")
        DispatchQueue.main.async {
//             最初のときだけ、テキストを空にしてからスタート
            if initial {
                super.attributedText = NSAttributedString(string: "")
            }

            // 現在のテキストに1文字追加
            let current = NSMutableAttributedString(attributedString: self.attributedText ?? NSAttributedString(string: ""))
            current.append(firstChar)
            super.attributedText = current

            self.dispatchSerialQ.asyncAfter(deadline: .now() + interval) {
                self.setAttributedTextWithTypingAnimation(remaining, interval, false, id)
            }
        }
    }

//     アニメーション用
    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize

//         ルビがある場合は上部に余白を追加
        if let attributedText = attributedText, attributedText.containsWideRubyAnnotation() {
            let rubyExtraHeight: CGFloat = 40
            return CGSize(width: originalSize.width, height: originalSize.height + rubyExtraHeight)
        }
        return originalSize
    }
//     アニメーション用
    override func drawText(in rect: CGRect) {
            super.drawText(in: rect)
    }
}

struct TypingRubyLabelRepresentable: UIViewRepresentable {
    let attributedText: NSAttributedString
    let charInterval: Double
    let font: UIFont
    let targetWidth: CGFloat

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
        uiView.maxLayoutWidth = targetWidth
        uiView.preferredMaxLayoutWidth = targetWidth
        uiView.attributedText = attributedText
    }
}
