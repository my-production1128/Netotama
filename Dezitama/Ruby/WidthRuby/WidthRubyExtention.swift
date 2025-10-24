//
//  extention.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/14.
//
import SwiftUI
import UIKit
import CoreText

// MARK: - String拡張：ルビ付きNSAttributedStringを生成
extension String {
    func createWideRuby(font: UIFont, color: UIColor = .black) -> NSAttributedString {

        // 改行の間隔を全部統一
        let generalLineSpacing: CGFloat = 40
        // ★ 削除： rubyLineSpacing の定義は不要になります
        // let rubyLineSpacing: CGFloat = font.pointSize * -1.0

        let generalParagraphStyle = NSMutableParagraphStyle()
        generalParagraphStyle.lineSpacing = generalLineSpacing

        // ★ 削除： rubyParagraphStyle の定義は不要になります
        // let rubyParagraphStyle = NSMutableParagraphStyle()
        // rubyParagraphStyle.lineSpacing = rubyLineSpacing

        let textWithRuby = replacingOccurrences(of: "(｜.+?《.+?》)", with: ",$1,", options: .regularExpression)
            .components(separatedBy: ",")
            .map { component -> NSAttributedString in
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

                    let attributes: [NSAttributedString.Key: Any] = [
                        kCTRubyAnnotationAttributeName as NSAttributedString.Key: rubyAnnotation,
                        .font: font,
                        .foregroundColor: color,
                        // ★★★ 修正箇所 ★★★
                        // rubyParagraphStyle ではなく、generalParagraphStyle を適用します
                        .paragraphStyle: generalParagraphStyle
                    ]

                    return NSAttributedString(string: baseText, attributes: attributes)
                } else {
                    // ルビがない部分もフォントを適用
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .foregroundColor: color,
                        .paragraphStyle: generalParagraphStyle // 改行用の広い行間を適用
                    ]
                    return NSAttributedString(string: component, attributes: attributes)
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
