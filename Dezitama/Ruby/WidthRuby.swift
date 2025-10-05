//
//  WidthRuby.swift
//  Dezitama_ver2
//
//  Created by 濱松未波 on 2025/07/04.
//
import SwiftUI
import UIKit
import CoreText


//会話画面におけるテキストのルビをふるコード
// MARK: - String拡張：ルビ付きNSAttributedStringを生成
extension String {
    func createWideRuby(font: UIFont, color: UIColor = .black) -> NSAttributedString {

//        改行の間隔を全部統一
        let generalLineSpacing: CGFloat = 15.0
        let rubyLineSpacing: CGFloat = font.pointSize * -0.5

        let generalParagraphStyle = NSMutableParagraphStyle()
        generalParagraphStyle.lineSpacing = generalLineSpacing

        let textWithRuby = replacingOccurrences(of: "(｜.+?《.+?》)", with: ",$1,", options: .regularExpression)
            .components(separatedBy: ",")
            .map { component -> NSAttributedString in
                if let _ = component.range(of: "｜(.+?)《(.+?)》", options: .regularExpression) {
                    let baseText = component.replacingOccurrences(of: "｜(.+?)《.+?》", with: "$1", options: .regularExpression)
                    let rubyText = component.replacingOccurrences(of: "｜.+?《(.+?)》", with: "$1", options: .regularExpression)

                    let rubyParagraphStyle = NSMutableParagraphStyle()
                    rubyParagraphStyle.lineSpacing = rubyLineSpacing

                    let rubyAttribute: [CFString: Any] = [
                        kCTRubyAnnotationSizeFactorAttributeName: 0.5,
                        kCTForegroundColorAttributeName: color
                    ]

                    let rubyAnnotation = CTRubyAnnotationCreateWithAttributes(
                        .auto, .auto, .before,
                        rubyText as CFString,
                        rubyAttribute as CFDictionary
                    )

                    let attributes: [NSAttributedString.Key: Any] = [
                        kCTRubyAnnotationAttributeName as NSAttributedString.Key: rubyAnnotation,
                        .font: font,
                        .foregroundColor: color,
                        .paragraphStyle: rubyParagraphStyle // ルビ用の狭い行間を適用
                    ]

                    return NSAttributedString(string: baseText, attributes: attributes)

                    // ...
//                    return NSAttributedString(
//                        string: baseText,
//                        attributes: [kCTRubyAnnotationAttributeName as NSAttributedString.Key: rubyAnnotation,
//                                     .font: font, // ← 修正！
//                                     .paragraphStyle: paragraphStyle
//                        ]
//                    )
                    // ...
                } else {
                    // ルビがない部分もフォントを適用
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .foregroundColor: color,
                        .paragraphStyle: generalParagraphStyle // 改行用の広い行間を適用
                    ]
                    return NSAttributedString(string: component, attributes: attributes)
//                    return NSAttributedString(string: component, attributes: [ // ← 修正！
//                        .font: font,
//                        .foregroundColor: color,
//                        .paragraphStyle: paragraphStyle
//                    ])
                }
            }
            .reduce(NSMutableAttributedString()) {
                $0.append($1)
                return $0
            }

        return textWithRuby
    }
}
// MARK: - NSAttributedString拡張：ルビ有無確認
extension NSAttributedString {
    func containsWideRubyAnnotation() -> Bool {
        var found = false
        self.enumerateAttribute(
            NSAttributedString.Key(rawValue: kCTRubyAnnotationAttributeName as String),
            in: NSRange(location: 0, length: self.length),
            options: []
        ) { value, _, stop in
            if value != nil {
                found = true
                stop.pointee = true
            }
        }
        return found
    }
}
// MARK: - カスタム UILabel (WideRubyLabel)
class WideRubyLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.textAlignment = .left  // ここでテキストアライメントを設定
    }

    override func drawText(in rect: CGRect) {
            super.drawText(in: rect)
    }

    override var intrinsicContentSize: CGSize {
        guard let attributedText = attributedText else {
            return super.intrinsicContentSize
        }

        if attributedText.containsWideRubyAnnotation() {
            let framesetter = CTFramesetterCreateWithAttributedString(attributedText)

            let unconstrainedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            let naturalSize = CTFramesetterSuggestFrameSizeWithConstraints(
                framesetter,
                CFRangeMake(0, attributedText.length),
                nil,
                unconstrainedSize,
                nil
            )

            let tempLabel = UILabel(frame: .zero)
            tempLabel.numberOfLines = 0
            tempLabel.lineBreakMode = .byWordWrapping
            tempLabel.font = self.font
            tempLabel.text = self.text
            tempLabel.attributedText = self.attributedText
            let maxAllowedWidth: CGFloat = 700

            if naturalSize.width <= maxAllowedWidth {
                return CGSize(width: ceil(naturalSize.width), height: ceil(naturalSize.height))
            } else {
                let constrainedSize = CGSize(width: maxAllowedWidth, height: CGFloat.greatestFiniteMagnitude)
                let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(
                    framesetter,
                    CFRangeMake(0, attributedText.length),
                    nil,
                    constrainedSize,
                    nil
                )
                return CGSize(width: ceil(frameSize.width), height: ceil(frameSize.height))
            }
        } else {
            let tempLabel = UILabel(frame: .zero)
            tempLabel.numberOfLines = 0
            tempLabel.lineBreakMode = .byWordWrapping
            tempLabel.font = self.font
            tempLabel.text = self.text
            tempLabel.attributedText = self.attributedText
            let maxAllowedWidth: CGFloat = 700
            let size = tempLabel.sizeThatFits(CGSize(width: maxAllowedWidth, height: CGFloat.greatestFiniteMagnitude))
            return CGSize(width: ceil(size.width), height: ceil(size.height))
        }
    }

    
}

// MARK: - SwiftUI ラッパー
struct WideRubyLabelRepresentable: UIViewRepresentable {
    let attributedText: NSAttributedString
    let font: UIFont
    let textColor: UIColor
    let textAlignment: NSTextAlignment

    func makeUIView(context: Context) -> WideRubyLabel {
        let style = NSMutableParagraphStyle()
//        style.lineSpacing = 20
        style.alignment = .center
        let label = WideRubyLabel()
        label.numberOfLines = 0
        label.textAlignment = .left  // ここでも設定
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ uiView: WideRubyLabel, context: Context) {
        uiView.attributedText = attributedText
        uiView.font = font
        uiView.textColor = textColor
        uiView.textAlignment = textAlignment  // 既存のプロパティを使用
    }

}


