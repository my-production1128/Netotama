//
//  NetomoView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/06.
//
import SwiftUI

struct NetomoView: View {
    // MARK: - State Properties
    @State private var currentIndex = 0
    @State private var isShowingLog = false
    
    // Typing Animation State
    @State private var displayedText = ""
    @State private var currentCharIndex = 0
    @State private var timer: Timer?
    @State private var isTypingComplete = false
    @State private var shouldSkipTyping = false
    
    // Button Animation State
    @State private var offsetY: CGFloat = 0.0
    
    // MARK: - Bindings
    @Binding var path: NavigationPath
    @Binding var netomoDialogues: [Dialogue]
    
    // MARK: - Constants
    private let talkFont = UIFont.customFont(ofSize: 30)
    private let charaNameFont = UIFont.customFont(ofSize: 35)
    private let typingInterval: TimeInterval = 0.05
    private let animationDuration: Double = 0.6
    private let animationOffset: CGFloat = 8.0
    private let chatBackgrounds = ["Chat"]
    private let rightCharacterName = "カール"

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            Group {
                if currentIndex < netomoDialogues.count {
                    sceneView(for: netomoDialogues[currentIndex], geometry: geometry)
                } else {
                    endSceneView
                }
            }
            .onAppear(perform: initializeTyping)
        }
    }
    
    // MARK: - End Scene View
    private var endSceneView: some View {
        ZStack {
            CommonUIComponents.backgroundImage("sky")
            
            CommonUIComponents.backToSelectionButton {
                path.removeLast()
            }
        }
    }
    
    // MARK: - Scene View Builder
    @ViewBuilder
    func sceneView(for current: Dialogue, geometry: GeometryProxy) -> some View {
        switch current.background {
        case "Introduction":
            introductionScene()
        case "Chat":
            chatScene(current: current)
        case "Park", "News":
            TalkingScene(current: current, geometry: geometry)
        case "Summary":
            summaryScene(current: current)
        default:
            defaultScene(current: current)
        }
    }
    
    // MARK: - Introduction Scene
    private func introductionScene() -> some View {
        ZStack {
            CommonUIComponents.backgroundImage("netotama_blackboard")
        }
        .onTapGesture(perform: handleSceneTap)
    }
    
    // MARK: - Chat Scene (Using ChatView)
    private func chatScene(current: Dialogue) -> some View {
        let chatDialogues = ChatSceneHelpers.getChatDialoguesFromCurrentIndex(
            dialogues: netomoDialogues,
            currentIndex: currentIndex,
            chatBackgrounds: chatBackgrounds
        )
        
        return ChatView(
            chatDialogues: chatDialogues,
            onNextScene: {
                ChatSceneHelpers.moveToNextNonChatScene(
                    dialogues: netomoDialogues,
                    currentIndex: &currentIndex,
                    chatBackgrounds: chatBackgrounds,
                    onStartTyping: { fullText in
                        startTyping(fullText: fullText)
                    }
                )
            },
            path: $path
        )
    }
    
    // MARK: - Talking Scene (Using TalkingView)
    private func TalkingScene(current: Dialogue, geometry: GeometryProxy) -> some View {
        ZStack {
            // TalkingViewコンポーネントを使用
            TalkingView(
                current: current,
                geometry: geometry,
                offsetY: $offsetY,
                onSceneTap: handleSceneTap,
                onStartLoopingAnimation: startLoopingAnimation
            )
            
            // オーバーレイボタン
            CommonUIComponents.overlayButtons(
                onHomeAction: { path.removeLast() },
                onLogAction: { isShowingLog.toggle() }
            )
            
            if isShowingLog {
                logOverlay(geometry: geometry.frame(in: .global))
            }
        }
    }
    
    // MARK: - Summary Scene
    private func summaryScene(current: Dialogue) -> some View {
        ZStack {
            CommonUIComponents.backgroundImage("sky")
            
            CommonUIComponents.rubyText(
                text: current.dialogueText,
                maxWidth: 600,
                font: talkFont,
                typingInterval: typingInterval
            )
            .padding()
            
            CommonUIComponents.backToSelectionButton {
                path.removeLast()
            }
        }
        .onTapGesture(perform: handleSceneTap)
    }
    
    // MARK: - Default Scene
    private func defaultScene(current: Dialogue) -> some View {
        ZStack {
            CommonUIComponents.backgroundImage("sky")
            
            CommonUIComponents.rubyText(
                text: current.dialogueText,
                maxWidth: 600,
                font: talkFont,
                typingInterval: typingInterval
            )
            .padding()
            
            CommonUIComponents.backToSelectionButton {
                path.removeLast()
            }
        }
        .onTapGesture(perform: handleSceneTap)
    }
    
    // MARK: - Character Display (Park Scene specific)
    private func characterDisplay(for current: Dialogue) -> some View {
        HStack {
            if current.characterName == "ニック" {
                Image("Nick")
                    .resizable()
                    .frame(width: 300, height: 700)
                    .offset(x: -50)
                
                Image("Curl")
                    .resizable()
                    .frame(width: 250, height: 550)
                    .offset(x: 50)
            } else {
                Image("Nick")
                    .resizable()
                    .frame(width: 250, height: 650)
                    .offset(x: -50)
                
                Image("Curl")
                    .resizable()
                    .frame(width: 300, height: 600)
                    .offset(x: 50)
            }
        }
    }
    
    // MARK: - Log Overlay
    private func logOverlay(geometry: CGRect) -> some View {
        LogComponents.logOverlay(
            dialogues: netomoDialogues,
            currentIndex: currentIndex,
            geometry: geometry
        ) { dialogue in
            AnyView(
                LogComponents.logMessageRow(
                    dialogue: dialogue,
                    rightCharacterName: rightCharacterName,
                    iconProvider: getCharacterIcon
                )
            )
        }
    }
}

// MARK: - Helper Methods
extension NetomoView {
    private func handleSceneTap() {
        timer?.invalidate()
        goToNextScene()
    }
    
    private func goToNextScene() {
        currentIndex += 1
        
        if currentIndex < netomoDialogues.count {
            let currentDialogue = netomoDialogues[currentIndex]
            
            // Chatシーンでない場合のみタイピングを開始
            if !chatBackgrounds.contains(currentDialogue.background) &&
               !currentDialogue.dialogueText.isEmpty {
                startTyping(fullText: currentDialogue.dialogueText)
            }
        }
    }
    
    private func initializeTyping() {
        if let firstDialogue = netomoDialogues.first {
            // 最初のシーンがChatでない場合のみタイピング開始
            if !chatBackgrounds.contains(firstDialogue.background) &&
               !firstDialogue.dialogueText.isEmpty {
                startTyping(fullText: firstDialogue.dialogueText)
            }
        }
    }
    
    private func startLoopingAnimation() {
        AnimationHelpers.startLoopingAnimation(
            offsetY: $offsetY,
            duration: animationDuration,
            offset: animationOffset
        )
    }

    private func startTyping(fullText: String) {
        AnimationHelpers.startTyping(
            fullText: fullText,
            displayedText: $displayedText,
            currentCharIndex: $currentCharIndex,
            timer: $timer,
            isTypingComplete: $isTypingComplete,
            typingInterval: typingInterval
        )
    }
}
