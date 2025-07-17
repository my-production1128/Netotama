//
//  CoreTextView.swift
//  Dezitama_ver2
//
//  Created by 濱松未波 on 2025/07/02.
//

import SwiftUI
import UIKit
import CoreText


//chattypeの時のルビを振るコード
// MARK: - String拡張：ルビ付きNSAttributedStringを生成
extension String {
    func createRuby(color: UIColor = .black) -> NSAttributedString {
        let textWithRuby = replacingOccurrences(of: "(｜.+?《.+?》)", with: ",$1,", options: .regularExpression)
            .components(separatedBy: ",")
            .map { component -> NSAttributedString in
                // ルビ形式のテキストの場合のみルビアノテーションを付与
                if let _ = component.range(of: "｜(.+?)《(.+?)》", options: .regularExpression) {
                    let baseText = component.replacingOccurrences(of: "｜(.+?)《.+?》", with: "$1", options: .regularExpression)
                    let rubyText = component.replacingOccurrences(of: "｜.+?《(.+?)》", with: "$1", options: .regularExpression)

                    let rubyAttribute: [CFString: Any] = [
                        kCTRubyAnnotationSizeFactorAttributeName: 0.5,
                        kCTForegroundColorAttributeName: color
                    ]

                    let rubyAnnotation = CTRubyAnnotationCreateWithAttributes(
                        .auto, .auto, .before,
                        rubyText as CFString,
                        rubyAttribute as CFDictionary
                    )

                    return NSAttributedString(
                        string: baseText,
                        attributes: [kCTRubyAnnotationAttributeName as NSAttributedString.Key: rubyAnnotation]
                    )
                } else {
                    // ルビがない部分はそのままNSAttributedStringで返す
                    return NSAttributedString(string: component)
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
    func containsRubyAnnotation() -> Bool {
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
//        print(attributedText)
        return found
    }
}

// MARK: - カスタム UILabel (RubyLabel)
class RubyLabel: UILabel {
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
    }

    override func drawText(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let attributedText = attributedText else {
            super.drawText(in: rect)
            return
        }

        if attributedText.containsRubyAnnotation() {
            context.translateBy(x: 0, y: rect.height)
            context.scaleBy(x: 1.0, y: -1.0)

            let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
            let frame = CTFramesetterCreateFrame(
                framesetter,
                CFRangeMake(0, attributedText.length),
                CGPath(rect: rect, transform: nil),
                nil
            )
            CTFrameDraw(frame, context)
        } else {
            super.drawText(in: rect)
        }
    }

    override var intrinsicContentSize: CGSize {
        guard let attributedText = attributedText else {
            return super.intrinsicContentSize
        }

        if attributedText.containsRubyAnnotation() {
            let framesetter = CTFramesetterCreateWithAttributedString(attributedText)

            // 💡 幅無制限で natural size を計算
            let unconstrainedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            let naturalSize = CTFramesetterSuggestFrameSizeWithConstraints(
                framesetter,
                CFRangeMake(0, attributedText.length),
                nil,
                unconstrainedSize,
                nil
            )

            let maxAllowedWidth: CGFloat = 270

            if naturalSize.width <= maxAllowedWidth {
                // 幅が許容範囲ならそのまま natural size を使う
                return CGSize(width: ceil(naturalSize.width), height: ceil(naturalSize.height))
            } else {
                // 幅が超えたら 340 に合わせた改行サイズを計算
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
            // 💡 ルビなし → UILabel の改行が効くように一時ラベルでサイズ計算
            let tempLabel = UILabel(frame: .zero)
            tempLabel.numberOfLines = 0
            tempLabel.lineBreakMode = .byWordWrapping
            tempLabel.font = self.font
            tempLabel.text = self.text
            tempLabel.attributedText = self.attributedText
            let maxAllowedWidth: CGFloat = 270
            let size = tempLabel.sizeThatFits(CGSize(width: maxAllowedWidth, height: CGFloat.greatestFiniteMagnitude))
            return CGSize(width: ceil(size.width), height: ceil(size.height))
        }
    }
}


// MARK:  SwiftUI ラッパー
struct RubyLabelRepresentable: UIViewRepresentable {
    let attributedText: NSAttributedString
    let font: UIFont
    let textColor: UIColor
    let textAlignment: NSTextAlignment

    func makeUIView(context: Context) -> RubyLabel {
        let label = RubyLabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ uiView: RubyLabel, context: Context) {
        uiView.attributedText = attributedText
        uiView.font = font
        uiView.textColor = textColor
        uiView.textAlignment = textAlignment
    }
}

