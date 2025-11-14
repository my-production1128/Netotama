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
    // 1. 外部から折り返し幅を指定するためのプロパティを追加
    let targetWidth: CGFloat

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.attributedText = attributedText
        label.font = font
        label.textColor = textColor
        label.textAlignment = textAlignment
        // 2. 指定された幅で折り返すように設定
        label.preferredMaxLayoutWidth = targetWidth
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedText
        uiView.font = font
        uiView.textColor = textColor
        uiView.textAlignment = textAlignment
        // 3. update時にも折り返し幅を再設定
        uiView.preferredMaxLayoutWidth = targetWidth
    }

    // 高さの自動計算 (これは変更なし)
    static func sizeThatFits(
        _ proposal: ProposedViewSize,
        attributedText: NSAttributedString,
        font: UIFont,
        textAlignment: NSTextAlignment
    ) -> CGSize {
        let label = UILabel()
        label.attributedText = attributedText
        label.font = font
        label.textAlignment = textAlignment
        label.numberOfLines = 0

        let targetSize = CGSize(width: proposal.width ?? 0, height: 0)
        let newSize = label.sizeThatFits(targetSize)
        return newSize
    }
}


