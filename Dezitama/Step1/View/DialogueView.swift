//
//  DialogueView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/10/01.
//

import SwiftUI

struct DialogueView: View {
    let dialogue: Dialogue2
    var onNext: (String) -> Void
    
    @State private var offsetY: CGFloat = 0.0
    @State private var animationTimer: Timer?
    
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
                handleTap()
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
    private func characterImage(_ imageName: String, size: (width: CGFloat, height: CGFloat), isSpeaking: Bool) -> some View {
        Image(imageName)
            .resizable()
            .frame(width: size.width, height: size.height)
            .saturation(isSpeaking ? 1.0 : 0.7)
            .brightness(isSpeaking ? 0.0 : -0.2)
            .scaleEffect(isSpeaking ? 1.0 : 0.95)
            .animation(.easeInOut(duration: 0.3), value: isSpeaking)
    }
    
    // MARK: - ダイアログコンポーネント
    @ViewBuilder
    private func dialogueComponentsGroup(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            
            ZStack {
                Image("speech_bubble_beige")
                    .resizable()
                    .frame(width: 1000, height: 300)
                
                VStack(alignment: .leading, spacing: 10) {
                    if let characterName = dialogue.characterName {
                        Text(characterName)
                            .font(Font(UIFont.customFont(ofSize: 30)))
                            .foregroundColor(.black)
                            .padding(.leading, 40)
                            .padding(.top, 20)
                    }
                    
                    if let dialogueText = dialogue.dialogueText {
                        TypingRubyLabelRepresentable(
                            attributedText: dialogueText
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createWideRuby(font: UIFont.customFont(ofSize: 30), color: .black),
                            charInterval: 0.05,
                            font: UIFont.customFont(ofSize: 30)
                        )
                        .frame(maxWidth: 700, alignment: .leading)
                        .padding(.horizontal, 60)
                    }
                    Spacer()
                }
                .frame(width: 1000, height: 300)
                
                // アニメーションはここに独立して置く
                AnimatedNextButton(action: handleTap)
                    .frame(width: 1000, height: 300)
            }
            .padding(.bottom, 150)
        }
    }

    // MARK: - ヘルパー関数
    private func isCharacterSpeaking(_ imageName: String) -> Bool {
        let characterName = getCharacterNameFromImage(imageName)
        return characterName == dialogue.characterName
    }
    
    private func getCharacterSize(for imageName: String) -> (width: CGFloat, height: CGFloat) {
        let isSpeaking = isCharacterSpeaking(imageName)
        let baseSize = getBaseCharacterSize(for: imageName)
        let multiplier: CGFloat = isSpeaking ? 1.2 : 1.0
        
        return (
            width: baseSize.width * multiplier,
            height: baseSize.height * multiplier
        )
    }
    
    private func getBaseCharacterSize(for imageName: String) -> (width: CGFloat, height: CGFloat) {
        let baseCharacterName = extractBaseCharacterName(from: imageName)
        
        switch baseCharacterName {
        case "Alec": return (250, 650)
        case "Cecil": return (250, 450)
        case "Cony": return (300, 500)
        case "Curl": return (250, 550)
        case "Teacher": return (300, 450)
        case "Brian": return (300, 450)
        case "Nick": return (250, 650)
        case "Sandra": return (250, 250)
        default: return (250, 450)
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
