////
////  CLTypingLabel.swift
////  Dezitama_ver2
////
////  Created by 濱松未波 on 2025/07/08.
////
//
//
////
////  CLTypingLabel.swift
////  CLTypingLabel
////  The MIT License (MIT)
////  Copyright © 2016 Chenglin 2/21/16.
////
////  Permission is hereby granted, free of charge, to any person obtaining a
////  copy of this software and associated documentation files
////  (the “Software”), to deal in the Software without restriction,
////  including without limitation the rights to use, copy, modify, merge,
////  publish, distribute, sublicense, and/or sell copies of the Software,
////  and to permit persons to whom the Software is furnished to do so,
////  subject to the following conditions:
////
////  The above copyright notice and this permission notice shall be included
////  in all copies or substantial portions of the Software.
////
////  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
////  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
////  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
////  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
////  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
////  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
////  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
////
//
//import UIKit
//
///*
// Set text at runtime to trigger type animation;
// 
// Set charInterval property for interval time between each character, default is 0.1;
// 
// Call pauseTyping() to pause animation;
// 
// Call continueTyping() to restart a paused animation;
// */
//
//
//@IBDesignable open class CLTypingLabel: UILabel {
//    @IBInspectable open var charInterval: Double = 0.1// 一文字ごとの表示間隔（秒）
//
//    open var onTypingAnimationFinished: (() -> Void)?// タイピングが最後まで終わったときに呼ばれるクロージャ（オプション）
//
////    @IBInspectable open var centerText: Bool = true// 表示のたびに文字列を中央寄せするかどうか
//
//    private var typingStopped: Bool = false// 一時停止中フラグ
//
//    private var typingOver: Bool = true// アニメーションが終了したかどうか
//
//    private var stoppedSubstring: String?// 停止時に残った文字列
//
//    private var attributes: [NSAttributedString.Key: Any]?// 属性付きテキストの場合の属性情報
//
//    private var currentDispatchID: Int = 320// アニメーションの一意識別子（途中で新しい text がセットされたときの管理用）
//
//    private let dispatchSerialQ = DispatchQueue(label: "CLTypingLableQueue")
//    // タイピング用のキュー（シリアルキュー）
//
//    // テキストをセットすると自動でアニメーションが始まる
//    override open var text: String! {
//        get {
//            return super.text
//        }
//        
//        set {
//            if charInterval < 0 {
//                charInterval = -charInterval
//            }
//            
//            currentDispatchID += 1
//            typingStopped = false
//            typingOver = false
//            stoppedSubstring = nil
//            
//            attributes = nil
//            setTextWithTypingAnimation(newValue, attributes,charInterval, true, currentDispatchID)
//        }
//    }
//    
//    // 属性付きテキストをセットすると自動でアニメーションが始まる
//    override open var attributedText: NSAttributedString! {
//        get {
//            return super.attributedText
//        }
//        
//        set {
//            if charInterval < 0 {
//                charInterval = -charInterval
//            }
//            
//            currentDispatchID += 1
//            typingStopped = false
//            typingOver = false
//            stoppedSubstring = nil
//            
//
//            attributes = newValue.attributes(at: 0, effectiveRange: nil)
//            setTextWithTypingAnimation(newValue.string, attributes,charInterval, true, currentDispatchID)
//        }
//    }
//    
//    // MARK: -
//    // MARK: Stop Typing Animation
//    // アニメーションを一時停止する
//    open func pauseTyping() {
//        if typingOver == false {
//            typingStopped = true
//        }
//    }
//    
//    // MARK: -
//    // MARK: Continue Typing Animation
//    // 一時停止を解除して続ける
//    open func continueTyping() {
//        
//        guard typingOver == false else {
////            print("CLTypingLabel: Animation is already over")
//            return
//        }
//        
//        guard typingStopped == true else {
////            print("CLTypingLabel: Animation is not stopped")
//            return
//        }
//        guard let stoppedSubstring = stoppedSubstring else {
//            return
//        }
//        
//        typingStopped = false
//        setTextWithTypingAnimation(stoppedSubstring, attributes ,charInterval, false, currentDispatchID)
//    }
//    
//    // MARK: -
//    // MARK: Set Text Typing Recursive Loop
//    // タイピングアニメーション本体のループ処理
//    private func setTextWithTypingAnimation(_ typedText: String, _ attributes: Dictionary<NSAttributedString.Key, Any>?, _ charInterval: TimeInterval, _ initial: Bool, _ dispatchID: Int) {
//
//        // 入力文字列が空 or 他のアニメーションが始まった場合は終了
//        guard !typedText.isEmpty && currentDispatchID == dispatchID else {
//            typingOver = true
//            typingStopped = false
//            if let nonNilBlock = onTypingAnimationFinished {
//                DispatchQueue.main.async(execute: nonNilBlock)
//            }
//            return
//        }
//
//        // 停止中なら、残りの文字列を保存して終了
//        guard typingStopped == false else {
//            stoppedSubstring = typedText
//            return
//        }
//        
//        if initial == true {
//            super.text = ""
//        }
//        
//        let firstCharIndex = typedText.index(typedText.startIndex, offsetBy: 1)
//        
//        DispatchQueue.main.async {
//            if let attributes = attributes {
//                // 属性付きテキストの場合
//                super.attributedText = NSAttributedString(string: super.attributedText!.string +  String(typedText[..<firstCharIndex]),
//                                                          attributes: attributes)
//            } else {
//                // プレーンテキストの場合
//                super.text = super.text! + String(typedText[..<firstCharIndex])
//            }
//            
////            if self.centerText == true {
////                self.sizeToFit()
////            }
//            self.dispatchSerialQ.asyncAfter(deadline: .now() + charInterval) { [weak self] in
//                let nextString = String(typedText[firstCharIndex...])
//                
//                self?.setTextWithTypingAnimation(nextString, attributes, charInterval, false, dispatchID)
//            }
//        }
//        
//    }
//}
//
//class ViewController: UIViewController {
//    let typingLabel = CLTypingLabel()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // ラベルの設定
//        typingLabel.charInterval = 0.05
//        typingLabel.textAlignment = .left  // 左寄せにする
//        typingLabel.numberOfLines = 0      // 複数行対応
//        typingLabel.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 200)
//        typingLabel.backgroundColor = .yellow.withAlphaComponent(0.2) // デバッグ用
//
//        view.addSubview(typingLabel)
//
//        // タイピング開始
//        typingLabel.text = "これは左上から表示されるタイピングアニメーションのテキストです。複数行もサポートします。"
//    }
//}
//
//
//import SwiftUI
//
//struct CLTypingLabelWrapper: UIViewRepresentable {
//    let text: String
//    let charInterval: Double
//
//    func makeUIView(context: Context) -> CLTypingLabel {
//        let label = CLTypingLabel()
//        label.textAlignment = .left        // ⭐ 左寄せ
//        label.numberOfLines = 0            // 複数行対応
//        label.charInterval = charInterval
//        label.backgroundColor = UIColor.yellow.withAlphaComponent(0.2) // デバッグ用背景
//        return label
//    }
//
//    func updateUIView(_ uiView: CLTypingLabel, context: Context) {
//        uiView.text = text
//    }
//}
