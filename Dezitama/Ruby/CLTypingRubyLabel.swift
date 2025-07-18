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
        self.textAlignment = .left  // ここでテキストアライメントを設定
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

//    private func setAttributedTextWithTypingAnimation(_ fullText: NSAttributedString, _ interval: Double, _ initial: Bool, _ id: Int) {
//        guard id == currentDispatchID else {
//            typingOver = true
//            return
//        }
//
//        if initial {
//            super.attributedText = NSAttributedString(string: "")
//        }
//
//        if fullText.length == 0 {
//            typingOver = true
//            return
//        }
//
//        let firstChar = fullText.attributedSubstring(from: NSRange(location: 0, length: 1))
//        let remaining = fullText.attributedSubstring(from: NSRange(location: 1, length: fullText.length - 1))
//
//        DispatchQueue.main.async {
//            let current = NSMutableAttributedString(attributedString: self.attributedText ?? NSAttributedString(string: ""))
//            current.append(firstChar)
//            super.attributedText = current
//
//            self.dispatchSerialQ.asyncAfter(deadline: .now() + interval) {
//                self.setAttributedTextWithTypingAnimation(remaining, interval, false, id)
//            }
//        }
//    }
    
    private func setAttributedTextWithTypingAnimation(_ fullText: NSAttributedString, _ interval: Double, _ initial: Bool, _ id: Int) {
        // ID確認ログ
//        print("➡️ [Typing] Called with id: \(id), currentDispatchID: \(currentDispatchID), initial: \(initial), fullText length: \(fullText.length), fullText:\(fullText)")

        guard id == currentDispatchID else {
//            print("⛔️ [Typing] Dispatch ID mismatch. Animation aborted.")
            typingOver = true
            return
        }

//        if initial {
//            print("🔄 [Typing] Initializing label text.")
//            super.attributedText = NSAttributedString(string: "")
//        }

        if fullText.length == 0 {
//            print("✅ [Typing] All characters displayed.")
            typingOver = true
            return
        }


        let firstCharRange = NSRange(location: 0, length: 1)
        let firstChar = fullText.attributedSubstring(from: firstCharRange)
        let remainingRange = NSRange(location: 1, length: fullText.length - 1)
        let remaining = fullText.length > 1 ? fullText.attributedSubstring(from: remainingRange) : NSAttributedString(string: "")
        DispatchQueue.main.async {
            // 最初のときだけ、テキストを空にしてからスタート
            if initial {
                super.attributedText = NSAttributedString(string: "")
            }
//        let firstChar = fullText.attributedSubstring(from: NSRange(location: 0, length: 1))
//        print("firstChar:",firstChar)
//        let remaining = fullText.attributedSubstring(from: NSRange(location: 1, length: fullText.length - 1))
//        print("remaining:",remaining)
//        DispatchQueue.main.async {
//            let current = NSMutableAttributedString(attributedString: self.attributedText ?? NSAttributedString(string: ""))
//            current.append(firstChar)
//            print("current:",current)
//            super.attributedText = current
//
//            print("🖋️ [Typing] Appended character: '\(firstChar.string)' | Remaining length: \(remaining.length)")
//
//            self.dispatchSerialQ.asyncAfter(deadline: .now() + interval) {
//                self.setAttributedTextWithTypingAnimation(remaining, interval, false, id)
//                print("1回終了")
//            }


            // 現在のテキストに1文字追加
            let current = NSMutableAttributedString(attributedString: self.attributedText ?? NSAttributedString(string: ""))
            current.append(firstChar)
            super.attributedText = current

//            print("🖋️ [Typing] Appended character: '\(firstChar.string)' | Remaining length: \(remaining.length)")

            self.dispatchSerialQ.asyncAfter(deadline: .now() + interval) {
                self.setAttributedTextWithTypingAnimation(remaining, interval, false, id)
//                print("1回終了")
            }
        }
    }


    // アニメーション用
    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize

        // ルビがある場合は上部に余白を追加
        if let attributedText = attributedText, attributedText.containsWideRubyAnnotation() {
            let rubyExtraHeight: CGFloat = 20 // ルビ用の追加高さ
            return CGSize(width: originalSize.width, height: originalSize.height + rubyExtraHeight)
        }

        return originalSize
    }


    // アニメーション用
    override func drawText(in rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext(), let attributedText = attributedText else {
//            super.drawText(in: rect)
//            return
//        }

//        if attributedText.containsRubyAnnotation() {
//            // Y座標を0に設定して、上端から描画開始
//            let drawingRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
//
//            context.saveGState()
//            context.translateBy(x: 0, y: drawingRect.height)
//            context.scaleBy(x: 1.0, y: -1.0)
//
//            let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
//            let path = CGPath(rect: drawingRect, transform: nil)
//            let frame = CTFramesetterCreateFrame(
//                framesetter,
//                CFRangeMake(0, attributedText.length),
//                path,
//                nil
//            )
//            CTFrameDraw(frame, context)
//            context.restoreGState()
//
//
//        } else {
            // 健全
        //
            super.drawText(in: rect)
//        }
    }


}


struct TypingRubyLabelRepresentable: UIViewRepresentable {
    let attributedText: NSAttributedString
    let charInterval: Double
    let font: UIFont

    func makeUIView(context: Context) -> CLTypingRubyLabel {
        let label = CLTypingRubyLabel()
        label.charInterval = charInterval
        label.textAlignment = .left// ここでも設定
        label.numberOfLines = 0
        label.font = font
        return label
    }

    func updateUIView(_ uiView: CLTypingRubyLabel, context: Context) {
        uiView.font = font
//        uiView.frame.size.width = 10
        uiView.attributedText = attributedText
    }
}
