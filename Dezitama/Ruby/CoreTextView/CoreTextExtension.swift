//
//  extension.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/14.
//
import SwiftUI
import UIKit
import CoreText

extension UIFont {
    static func customFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "MPLUS1-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

// MARK: - String拡張：ルビ付きNSAttributedStringを生成
extension String {
    func createRuby(font: UIFont, color: UIColor = .black) -> NSAttributedString {
        let textWithRuby = replacingOccurrences(of: "(｜.+?《.+?》)", with: ",$1,", options: .regularExpression)
            .components(separatedBy: ",")
            .map { component -> NSAttributedString in
                // ルビ形式のテキストの場合のみルビアノテーションを付与
                if let _ = component.range(of: "｜(.+?)《(.+?)》", options: .regularExpression) {
                    let baseText = component.replacingOccurrences(of: "｜(.+?)《.+?》", with: "$1", options: .regularExpression)
                    let rubyText = component.replacingOccurrences(of: "｜.+?《(.+?)》", with: "$1", options: .regularExpression)

                    // ▼▼▼ ここから追加・修正 ▼▼▼
                    let paragraphStyle = NSMutableParagraphStyle()
                    // 行間を調整してルビと本文の距離を近づけます。
                    paragraphStyle.lineSpacing = font.pointSize * 0.5
                    // ▲▲▲ ここまで追加・修正 ▲▲▲

                    let rubyAttribute: [CFString: Any] = [
                        kCTRubyAnnotationSizeFactorAttributeName: 0.42,
                        kCTForegroundColorAttributeName: color
                    ]

                    let rubyAnnotation = CTRubyAnnotationCreateWithAttributes(
                        .auto, .auto, .before,
                        rubyText as CFString,
                        rubyAttribute as CFDictionary
                    )

                    return NSAttributedString(
                        string: baseText,
                        attributes: [kCTRubyAnnotationAttributeName as NSAttributedString.Key: rubyAnnotation,
                                     .font: font // ← 修正！
//                                     .paragraphStyle: paragraphStyle
                        ]
                    )
                } else {
                    // ルビがない部分もフォントを適用
                    return NSAttributedString(string: component, attributes: [ // ← 修正！
                        .font: font,
                        .foregroundColor: color
                    ])
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
        return found
    }
}
