//
//  DialogueView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/10/01.
//

import SwiftUI

struct DialogueView: View {
    let dialogue: Dialogue2
    let nextDialogue: Dialogue2?
    var onNext: (String) -> Void
    
    @State private var offsetY: CGFloat = 0.0
    @State private var animationTimer: Timer?
    @State private var isTypingComplete: Bool = false
    @State private var hasAutoProgressed: Bool = false
    @State private var hasAppeared: Bool = false // ★ 初回表示フラグ
    
    @State private var isPopupVisible: Bool = false
    @State private var currentChoiceDialogue: Dialogue2? = nil
    
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
                
                // ★ 選択肢ポップアップ
                if isPopupVisible, let choiceDialogue = currentChoiceDialogue {
                    BadChoiceView(
                        dialogue: choiceDialogue,
                        isPopupVisible: $isPopupVisible,
                        onChoiceSelected: { selectedText, nextId, percentage in
                            handleChoiceSelected(selectedText: selectedText,
                                                 nextId: nextId,
                                                 percentage: percentage)
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                handleTap()
            }
        }
        .onAppear {
            // ★ 初回表示時のみアニメーション開始
            if dialogue.isChoice != true {
                startLoopingAnimation()
            }
            
            hasAutoProgressed = false
            
            // ★ 現在のシーンが選択肢の場合
            if dialogue.isChoice == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        isPopupVisible = true
                    }
                }
            }
            // ★ 次が選択肢の場合は自動遷移
            else if let next = nextDialogue, next.isChoice == true {
                autoProgressToChoice()
            }
        }
        .onDisappear {
            // ★ 画面が消える時にアニメーション停止
            stopLoopingAnimation()
            hasAppeared = false
        }
    }
    
    // MARK: - 選択肢への自動遷移
    private func autoProgressToChoice() {
        guard !hasAutoProgressed else {
            return
        }
        
        // タイピング時間を計算
        let text = dialogue.dialogueText ?? ""
        let typingTime = Double(text.count) * 0.05 + 1.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + typingTime) {
            guard !self.hasAutoProgressed else {
                return
            }
            self.hasAutoProgressed = true
            
            if let nextId = self.dialogue.nextSceneId {
                self.stopLoopingAnimation()
                self.onNext(nextId)
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
                // 吹き出し背景
                Image("speech_bubble_beige")
                    .resizable()
                    .frame(width: 1000, height: 300)
                
                VStack(alignment: .leading, spacing: 10) {
                    // キャラ名
                    if let characterName = dialogue.characterName {
                        Text(characterName)
                            .font(Font(UIFont.customFont(ofSize: 30)))
                            .foregroundColor(.black)
                            .padding(.leading, 60)
                            .padding(.top, 20)
                    }
                    
                    // セリフテキスト
                    if let dialogueText = dialogue.dialogueText {
                        if dialogue.isChoice == true {
                            // 選択肢の場合はタイピングなしで即表示
                            RubyLabelRepresentable(
                                attributedText: dialogueText
                                    .replacingOccurrences(of: "<br>", with: "\n")
                                    .createWideRuby(font: UIFont.customFont(ofSize: 30), color: .black),
                                font: UIFont.customFont(ofSize: 30),
                                textColor: .black,
                                textAlignment: .left
                            )
                            .frame(maxWidth: 700, alignment: .leading)
                            .padding(.horizontal, 60)
                            .id(dialogueText)
                        } else {
                            // 通常はタイピングアニメーション
                            TypingRubyLabelRepresentable(
                                attributedText: dialogueText
                                    .replacingOccurrences(of: "<br>", with: "\n")
                                    .createWideRuby(font: UIFont.customFont(ofSize: 30), color: .black),
                                charInterval: 0.05,
                                font: UIFont.customFont(ofSize: 30)
                            )
                            .frame(maxWidth: 700, alignment: .leading)
                            .padding(.horizontal, 60)
                            .id(dialogueText)
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: 1000, height: 300)
                
                // 次へボタン(選択肢の時、または次が選択肢の時は非表示)
                if dialogue.isChoice != true, nextDialogue?.isChoice != true {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: handleTap) {
                                Image("next_button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                            }
                            .offset(y: offsetY)
                            .padding(.trailing, 60)
                            .padding(.bottom, 30)
                        }
                    }
                    .frame(width: 1000, height: 300)
                }
            }
            .padding(.bottom, 50)
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
        case "Cony": return (250, 450)
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
    
    // MARK: - アニメーション管理
    private func startLoopingAnimation() {
        stopLoopingAnimation()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.7)) {
                offsetY = offsetY == 0 ? -10 : 0
            }
        }
    }
    
    private func stopLoopingAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        offsetY = 0
    }
    
    // MARK: - イベント処理
    private func handleTap() {
        // すでに選択肢表示中なら無視
        if isPopupVisible { return }
        
        // 現在のdialogueが選択肢の場合
        if dialogue.isChoice == true {
            withAnimation {
                isPopupVisible = true
                currentChoiceDialogue = dialogue
            }
            return
        }

        // 通常の進行（次へ）
        if let nextSceneId = dialogue.nextSceneId {
            hasAutoProgressed = true
            stopLoopingAnimation()
            onNext(nextSceneId)
        }
    }

    // MARK: - 選択肢選択時の処理
    private func handleChoiceSelected(selectedText: String, nextId: String, percentage: String?) {
        if let percentageStr = percentage, let percentageValue = Double(percentageStr) {
            gameManager.addScore(percentage: percentageValue)
        }
        
        isPopupVisible = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onNext(nextId)
        }
    }
}

// MARK: - Dialogue2 Extension
extension Dialogue2 {
    var safeLeftCharacter: String { self.leftCharacter ?? "" }
    var safeCenterCharacter: String { self.centerCharacter ?? "" }
    var safeRightCharacter: String { self.rightCharacter ?? "" }
    var safeOneCharacter: String { self.oneCharacter ?? "" }
    var safeTwoCharacter: String { self.twoCharacter ?? "" }
    var safeOnePerson: String { self.onePerson ?? "" }
    var safeTalkingPeople: String { self.talkingPeople ?? "" }
}
