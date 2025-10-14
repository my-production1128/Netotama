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
// MARK: - カスタム UILabel (WideRubyLabel)
class WideRubyLabel: UILabel {


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
        self.textAlignment = .left
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

            if naturalSize.width <= self.maxLayoutWidth {
                return CGSize(width: ceil(naturalSize.width), height: ceil(naturalSize.height))
            } else {
                let constrainedSize = CGSize(width: self.maxLayoutWidth, height: CGFloat.greatestFiniteMagnitude)
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
            let size = tempLabel.sizeThatFits(CGSize(width: self.maxLayoutWidth, height: CGFloat.greatestFiniteMagnitude))
            return CGSize(width: ceil(size.width), height: ceil(size.height))
        }    }

    
}

// MARK: - SwiftUI ラッパー
struct WideRubyLabelRepresentable: UIViewRepresentable {
    let attributedText: NSAttributedString
    let font: UIFont
    let textColor: UIColor
    let textAlignment: NSTextAlignment

    func makeUIView(context: Context) -> WideRubyLabel {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let label = WideRubyLabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ uiView: WideRubyLabel, context: Context) {
        uiView.attributedText = attributedText
        uiView.font = font
        uiView.textColor = textColor
        uiView.textAlignment = textAlignment
    }

}


