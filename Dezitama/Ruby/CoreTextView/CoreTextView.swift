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
// MARK: - カスタム UILabel (RubyLabel)
class RubyLabel: UILabel {
    var maxLayoutWidth: CGFloat = UIScreen.main.bounds.width

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

            let unconstrainedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            let naturalSize = CTFramesetterSuggestFrameSizeWithConstraints(
                framesetter,
                CFRangeMake(0, attributedText.length),
                nil,
                unconstrainedSize,
                nil
            )

            // let maxAllowedWidth: CGFloat = 270 <- この行を削除

            if naturalSize.width <= self.maxLayoutWidth { // 👈 変更
                return CGSize(width: ceil(naturalSize.width), height: ceil(naturalSize.height))
            } else {
                let constrainedSize = CGSize(width: self.maxLayoutWidth, height: CGFloat.greatestFiniteMagnitude) // 👈 変更
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
            // let maxAllowedWidth: CGFloat = 270 <- この行を削除
            let size = tempLabel.sizeThatFits(CGSize(width: self.maxLayoutWidth, height: CGFloat.greatestFiniteMagnitude)) // 👈 変更
            return CGSize(width: ceil(size.width), height: ceil(size.height))
        }    }
}


// MARK: - SwiftUI ラッパー
struct RubyLabelRepresentable: UIViewRepresentable {
    let attributedText: NSAttributedString
    let font: UIFont
    let textColor: UIColor
    let textAlignment: NSTextAlignment
    let targetWidth: CGFloat

    func makeUIView(context: Context) -> RubyLabel {
        let label = RubyLabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ uiView: RubyLabel, context: Context) {
        uiView.maxLayoutWidth = targetWidth
        uiView.preferredMaxLayoutWidth = targetWidth
        uiView.attributedText = attributedText
        uiView.font = font
        uiView.textColor = textColor
        uiView.textAlignment = textAlignment
    }
}



