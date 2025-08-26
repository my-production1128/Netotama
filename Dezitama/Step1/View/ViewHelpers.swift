//
//  ViewHelpers.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/08/20.
//

import SwiftUI

// MARK: - 再利用可能なView関数

/// 背景画像を表示するView
/// - Parameter imageName: 画像ファイル名
/// - Returns: 背景画像View
func backgroundImage(_ imageName: String) -> some View {
    Image(imageName)
        .resizable()
        .scaledToFill()
        .ignoresSafeArea()
}

/// キャラクターアイコンを表示するView
/// - Parameters:
///   - characterName: キャラクター名
///   - size: アイコンサイズ（デフォルト：48）
/// - Returns: キャラクターアイコンView
func characterIcon(for characterName: String, size: CGFloat = 48) -> some View {
    Image(getCharacterIcon(for: characterName))
        .resizable()
        .frame(width: size, height: size)
        .clipShape(Circle())
}

/// キャラクター名からアイコン名を取得
/// - Parameter characterName: キャラクター名
/// - Returns: アイコンファイル名
func getCharacterIcon(for characterName: String) -> String {
    switch characterName {
    case "アレック": return "alec_icon"
    case "セシル": return "cecil_icon"
    case "コニー": return "cony_icon"
    case "ブライアン": return "brian_icon"
    case "カール": return "curl_icon"
    case "ケビン": return "kevin_icon"
    case "ロビー": return "robby_icon"
    case "サンドラ": return "sandra_icon"
    case "先生": return "teacher_icon"
    case "ニック": return "nick_icon"
    default: return "default_icon"
    }
}

/// ホームボタン
/// - Parameter action: ボタンタップ時のアクション
/// - Returns: ホームボタンView
func homeButton(action: @escaping () -> Void) -> some View {
    HStack {
        Spacer()
        VStack {
            Button(action: action) {
                Image("home")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 30)
            }
            Spacer()
        }
    }
}


// MARK: - Common UI Components
struct CommonUIComponents {
    
    // MARK: - Background Image
    static func backgroundImage(_ imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    // MARK: - Ruby Text with Typing Animation
    static func rubyText(
        text: String,
        maxWidth: CGFloat,
        font: UIFont = UIFont.customFont(ofSize: 30),
        typingInterval: TimeInterval = 0.05
    ) -> some View {
        TypingRubyLabelRepresentable(
            attributedText: text
                .replacingOccurrences(of: "<br>", with: "\n")
                .createWideRuby(font: font, color: .black),
            charInterval: typingInterval,
            font: font
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: maxWidth)
    }
    
    // MARK: - Home Button
    static func homeButton(action: @escaping () -> Void) -> some View {
        HStack {
            Spacer()
            VStack {
                Button(action: action) {
                    Image("home")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 30)
                }
                Spacer()
            }
        }
    }
    
    // MARK: - Log Button
    static func logButton(action: @escaping () -> Void) -> some View {
        HStack {
            VStack {
                Button(action: action) {
                    Image("chat")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                }
                Spacer()
            }
            Spacer()
        }
        .padding(50)
        .zIndex(2)
    }
    
    // MARK: - Back to Selection Button
    static func backToSelectionButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image("story_back")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .padding()
        }
        .offset(x: 400, y: 300)
    }
    
    // MARK: - Overlay Buttons Group
    static func overlayButtons(
        onHomeAction: @escaping () -> Void,
        onLogAction: @escaping () -> Void
    ) -> some View {
        Group {
            homeButton(action: onHomeAction)
            logButton(action: onLogAction)
        }
    }
    
    // MARK: - Character Icon
    static func characterIcon(
        for characterName: String,
        isRight: Bool = false,
        iconProvider: (String) -> String
    ) -> some View {
        let iconName = iconProvider(characterName)
        
        return Image(iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .clipShape(Circle())
    }
}

// MARK: - Log Components
struct LogComponents {
    
    // MARK: - Log Overlay
    static func logOverlay<T: Identifiable>(
        dialogues: [T],
        currentIndex: Int,
        geometry: CGRect,
        messageRowBuilder: @escaping (T) -> AnyView
    ) -> some View where T: Any {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(1...currentIndex, id: \.self) { index in
                    if index < dialogues.count {
                        messageRowBuilder(dialogues[index])
                            .id(index)
                    }
                }
            }
            .padding(.top, 0)
            .padding(.bottom, 0)
            .padding(.horizontal)
        }
        .background(Color.black.opacity(0.6))
        .cornerRadius(16)
        .frame(width: geometry.width / 2, height: .infinity)  // heightを.infinityに変更
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .transition(.move(edge: .leading))
        .zIndex(1)
        .clipped()
    }
    
    // MARK: - Generic Log Message Row
    static func logMessageRow(
        dialogue: Dialogue,
        rightCharacterName: String,
        iconProvider: (String) -> String
    ) -> some View {
        let isRight = dialogue.characterName == rightCharacterName
        
        return HStack(alignment: .bottom, spacing: 8) {
            if isRight { Spacer() }
            
            if !isRight {
                CommonUIComponents.characterIcon(
                    for: dialogue.characterName,
                    iconProvider: iconProvider
                )
            }
            
            VStack(alignment: isRight ? .trailing : .leading, spacing: 4) {
                Text(dialogue.characterName)
                    .font(Font(UIFont.customFont(ofSize: 16)))
                    .foregroundColor(.white)
                
                CommonUIComponents.rubyText(
                    text: dialogue.dialogueText,
                    maxWidth: 230,  // ボタンとの重複を避けるため少し狭く
                    font: UIFont.customFont(ofSize: 20),
                    typingInterval: 0
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
            }
            .frame(maxWidth: 250, alignment: isRight ? .trailing : .leading)
            
            if isRight {
                CommonUIComponents.characterIcon(
                    for: dialogue.characterName,
                    isRight: true,
                    iconProvider: iconProvider
                )
            }
            
            if !isRight { Spacer() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Animation Helpers
struct AnimationHelpers {
    
    // MARK: - Button Loop Animation
    static func startLoopingAnimation(
        offsetY: Binding<CGFloat>,
        duration: Double = 0.6,
        offset: CGFloat = 8.0
    ) {
        offsetY.wrappedValue = 0.0
        let animation = Animation
            .easeInOut(duration: duration)
            .repeatForever(autoreverses: true)

        withAnimation(animation) {
            offsetY.wrappedValue = offset
        }
    }
    
    // MARK: - Typing Animation
    static func startTyping(
        fullText: String,
        displayedText: Binding<String>,
        currentCharIndex: Binding<Int>,
        timer: Binding<Timer?>,
        isTypingComplete: Binding<Bool>,
        typingInterval: TimeInterval = 0.05
    ) {
        displayedText.wrappedValue = ""
        currentCharIndex.wrappedValue = 0
        timer.wrappedValue?.invalidate()

        timer.wrappedValue = Timer.scheduledTimer(withTimeInterval: typingInterval, repeats: true) { t in
            if currentCharIndex.wrappedValue < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentCharIndex.wrappedValue)
                displayedText.wrappedValue.append(fullText[index])
                currentCharIndex.wrappedValue += 1
            } else {
                t.invalidate()
                timer.wrappedValue = nil
                isTypingComplete.wrappedValue = true
            }
        }
    }
}

// MARK: - Chat Scene Helpers
struct ChatSceneHelpers {
    
    // MARK: - Get Chat Dialogues from Current Index
    static func getChatDialoguesFromCurrentIndex(
        dialogues: [Dialogue],
        currentIndex: Int,
        chatBackgrounds: [String]
    ) -> [Dialogue] {
        var chatDialogues: [Dialogue] = []
        var tempIndex = currentIndex
        
        guard currentIndex < dialogues.count else { return chatDialogues }
        let currentBackground = dialogues[currentIndex].background
        
        while tempIndex < dialogues.count &&
              (chatBackgrounds.contains(dialogues[tempIndex].background) ||
               dialogues[tempIndex].background == currentBackground) {
            chatDialogues.append(dialogues[tempIndex])
            tempIndex += 1
        }
        
        return chatDialogues
    }
    
    // MARK: - Move to Next Non-Chat Scene
    static func moveToNextNonChatScene(
        dialogues: [Dialogue],
        currentIndex: inout Int,
        chatBackgrounds: [String],
        onStartTyping: (String) -> Void
    ) {
        guard currentIndex < dialogues.count else { return }
        let currentBackground = dialogues[currentIndex].background
        var nextIndex = currentIndex
        
        // 現在のChatシーン群の終了位置を見つける
        while nextIndex < dialogues.count &&
              (chatBackgrounds.contains(dialogues[nextIndex].background) ||
               dialogues[nextIndex].background == currentBackground) {
            nextIndex += 1
        }
        
        // Chat以外の次のシーンに移動
        currentIndex = nextIndex
        
        // 次のシーンがある場合、タイピングを開始
        if currentIndex < dialogues.count {
            let nextDialogue = dialogues[currentIndex]
            if !nextDialogue.dialogueText.isEmpty &&
               !chatBackgrounds.contains(nextDialogue.background) {
                onStartTyping(nextDialogue.dialogueText)
            }
        }
    }
}
