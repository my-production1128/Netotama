//
//  DialogueView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/10/01.
//

import SwiftUI

struct DialogueView: View {
    let dialogue: Dialogue2
    var isChoicePending: Bool
    var onNext: (String) -> Void
    
    @State private var offsetY: CGFloat = 0.0
    @State private var animationTimer: Timer?
    // 会話アニメーション準備完了フラグ
    @State private var isAnimationReady: Bool = false

    @EnvironmentObject private var gameManager: GameManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                if let background = dialogue.background, !background.isEmpty {
                    Image(background)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
                
                // キャラクター配置
                characterLayoutView(geometry: geometry)
                
                // ダイアログコンポーネント
                dialogueComponentsGroup(geometry: geometry)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // アニメーション準備完了後のみタップを受け付ける
                if isAnimationReady {
                    handleTap()
                }
            }
            .onAppear {
                if isChoicePending {
                                    // 選択肢表示中は、タイマーを待たずにタップ（次へ進む動作）を許可
                                    isAnimationReady = true
                                } else {
                                    // 通常時（既存のコード）
                                    isAnimationReady = false
                                    if let dialogueText = dialogue.dialogueText {
                                        let textLength = dialogueText.replacingOccurrences(of: "<br>", with: "").count
                                        let typingDuration = Double(textLength) * 0.03 + 0.1 // 0.05秒/文字 + バッファ0.3秒

                                        // タイピング完了後にタップを有効化
                                        DispatchQueue.main.asyncAfter(deadline: .now() + typingDuration) {
                                            isAnimationReady = true
                                        }
                                    }
                                }
            }
        }
    }
    
    // MARK: - キャラクター配置
    @ViewBuilder
    private func characterLayoutView(geometry: GeometryProxy) -> some View {
        if let talkingPeople = dialogue.talkingPeople {
            switch talkingPeople {
            case "Three":
                threePersonLayout
            case "Two":
                twoPersonLayout
            case "One":
                onePersonLayout
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - 3人レイアウト
    private var threePersonLayout: some View {
        Group {
            if let leftChar = dialogue.leftCharacter, !leftChar.isEmpty {
                characterImage(
                    leftChar,
                    size: getCharacterSize(for: leftChar),
                    isSpeaking: isCharacterSpeaking(leftChar)
                )
                .offset(x: -300)
            }
            
            if let centerChar = dialogue.centerCharacter, !centerChar.isEmpty {
                characterImage(
                    centerChar,
                    size: getCharacterSize(for: centerChar),
                    isSpeaking: isCharacterSpeaking(centerChar)
                )
                .offset(x: 0)
            }
            
            if let rightChar = dialogue.rightCharacter, !rightChar.isEmpty {
                characterImage(
                    rightChar,
                    size: getCharacterSize(for: rightChar),
                    isSpeaking: isCharacterSpeaking(rightChar)
                )
                .offset(x: 300)
            }
        }
    }
    
    // MARK: - 2人レイアウト
    private var twoPersonLayout: some View {
        HStack(spacing: 200) {
            if let oneChar = dialogue.oneCharacter, !oneChar.isEmpty {
                characterImage(
                    oneChar,
                    size: getCharacterSize(for: oneChar),
                    isSpeaking: isCharacterSpeaking(oneChar)
                )
            }
            
            if let twoChar = dialogue.twoCharacter, !twoChar.isEmpty {
                characterImage(
                    twoChar,
                    size: getCharacterSize(for: twoChar),
                    isSpeaking: isCharacterSpeaking(twoChar)
                )
            }
        }
    }
    
    // MARK: - 1人レイアウト
    private var onePersonLayout: some View {
        Group {
            if let onePerson = dialogue.onePerson, !onePerson.isEmpty {
                characterImage(
                    onePerson,
                    size: getCharacterSize(for: onePerson),
                    isSpeaking: true
                )
            }
        }
    }
    
    // MARK: - キャラクター画像
    private func characterImage(_ imageName: String, size height: CGFloat, isSpeaking: Bool) -> some View { // size: (width: CGFloat, height: CGFloat) から size height: CGFloat へ
            Image(imageName)
                .resizable()
                .scaledToFit() // ← .scaledToFit() を追加
                .frame(height: height) // ← .frame で height だけを指定
                .saturation(isSpeaking ? 1.0 : 0.7)
                .brightness(isSpeaking ? 0.0 : -0.2)
                .scaleEffect(isSpeaking ? 1.0 : 0.95) // ← scaleEffect は isSpeaking 判定後に適用した方が良いかも？
                                                     //    (ただし、元のコードの意図を尊重してこのままにします)
                .animation(.easeInOut(duration: 0.3), value: isSpeaking)
        }

    // MARK: - ダイアログコンポーネント
    @ViewBuilder
    private func dialogueComponentsGroup(geometry: GeometryProxy) -> some View {
        Group {
            ZStack {
                Image("speech_bubble_beige")
                    .resizable()
                    .frame(width: 950, height: 250)
                    .offset(x:-13, y: 0)
                    .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.8)

                if let characterName = dialogue.characterName {
                    Text(characterName)
                        .font(.custom("MPLUS1-Regular", size: 35))
                        .font(.title)
                        .padding(6)
                        .cornerRadius(8)
                        .position(x: geometry.size.width * 0.22,y: geometry.size.height * 0.677)
                }

                if let dialogueText = dialogue.dialogueText {
                    let attributedText = dialogueText
                                            .replacingOccurrences(of: "<br>", with: "\n")
                                            .createWideRuby(font: UIFont.customFont(ofSize: 30), color: .black)

                                        let font = UIFont.customFont(ofSize: 30)
                                        let targetWidth: CGFloat = 500

                                        if isChoicePending {
                                            // 【選択肢表示中】アニメーションなしのテキストを表示
                                            WideRubyLabelRepresentable(
                                                attributedText: attributedText,
                                                font: font,
                                                textColor: .black,
                                                textAlignment: .natural,
                                                targetWidth: targetWidth
                                            )
                                            .fixedSize(horizontal: false, vertical: true)
                                            .frame(maxWidth: 700)
                                            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)

                                        } else {
                                            // 【通常時】タイピングアニメーションを表示 (既存のコード)
                                            TypingRubyLabelRepresentable(
                                                attributedText: attributedText,
                                                charInterval: 0.05,
                                                font: font,
                                                targetWidth: targetWidth
                                            )
                                            .fixedSize(horizontal: false, vertical: true)
                                            .frame(maxWidth: 700)
                                            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)
                                        }
                }

                HStack {
                    Image("next_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                        .position(x: geometry.size.width * 0.85,y: geometry.size.height * 0.905)
                        .offset(y: offsetY)
                        .onAppear {
                            startLoopingAnimation()
                        }
                }
            }
        }.offset(y: 20)
    }

    // MARK: - ヘルパー関数
    private func startLoopingAnimation() {
        offsetY = 0.0
        let animation = Animation
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)

        withAnimation(animation) {
            offsetY = 8.0
        }
    }

    private func isCharacterSpeaking(_ imageName: String) -> Bool {
        let characterName = getCharacterNameFromImage(imageName)
        return characterName == dialogue.characterName
    }
    
    private func getCharacterSize(for imageName: String) -> CGFloat { // (width: CGFloat, height: CGFloat) から CGFloat へ
            let isSpeaking = isCharacterSpeaking(imageName)
            let baseHeight = getBaseCharacterSize(for: imageName) // baseSize から baseHeight へ
            let multiplier: CGFloat = isSpeaking ? 1.1 : 1.0

            return baseHeight * multiplier // height だけを返す
        }

    private func getBaseCharacterSize(for imageName: String) -> CGFloat { // (width: CGFloat, height: CGFloat) から CGFloat へ
            let baseCharacterName = extractBaseCharacterName(from: imageName)
            switch baseCharacterName {
            // 幅はコメントアウトし、高さだけを返す
            case "Alec":    return 500 // (width: 350, height: 650)
            case "Cecil":   return 500 // (width: 250, height: 450)
            case "Cony":    return 500 // (width: 300, height: 500)
            case "Curl":    return 500 // (width: 250, height: 550)
            case "Teacher": return 500 // (width: 300, height: 450)
            case "Brian":   return 500 // (width: 300, height: 450)
            case "Nick":    return 500 // (width: 250, height: 650)
            case "Sandra":  return 300 // (width: 250, height: 250)
            default:        return 500 // (width: 250, height: 450)
            }
        }

    private func extractBaseCharacterName(from imageName: String) -> String {
        return imageName.components(separatedBy: "_").first ?? imageName
    }
    
    private func getCharacterNameFromImage(_ imageName: String) -> String {
        let baseName = extractBaseCharacterName(from: imageName)
        
        switch baseName {
        case "Alec": return "アレック"
        case "Cecil": return "セシル"
        case "Cony": return "コニー"
        case "Curl": return "カール"
        case "Teacher": return "先生"
        case "Nick": return "ニック"
        case "Sandra": return "サンドラ"
        case "Brian": return "ブライアン"
        default: return ""
        }
    }
    
    // MARK: - イベント処理
    private func handleTap() {
        // 通常の進行
        if let nextSceneId = dialogue.nextSceneId {
            onNext(nextSceneId)
        }
    }
}


// MARK: - 「次へ」ボタンのゆらゆらアニメーション
struct AnimatedNextButton: View {
    var action: () -> Void
    @State private var offsetY: CGFloat = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image("next_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                        .offset(y: offsetY)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 0.7)
                                .repeatForever(autoreverses: true)
                            ) {
                                offsetY = -10
                            }
                        }
                }
                .padding(.trailing, 60)
                .padding(.bottom, 30)
            }
        }
    }
}
