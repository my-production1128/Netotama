//
//  KakusanView.swift
//  Dezitama
//
//  Created by AI Assistant on 2025/08/24.
//

import SwiftUI

struct KakusanView: View {
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
    @Binding var kakusanDialogues: [Dialogue]
    
    // MARK: - Constants
    private let talkFont = UIFont.customFont(ofSize: 30)
    private let charaNameFont = UIFont.customFont(ofSize: 35)
    private let typingInterval: TimeInterval = 0.05
    private let animationDuration: Double = 0.6
    private let animationOffset: CGFloat = 8.0
    private let chatBackgrounds = ["Chat1", "Chat2", "Chat3"]
    private let rightCharacterName = "セシル"

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            Group {
                if currentIndex < kakusanDialogues.count {
                    sceneView(for: kakusanDialogues[currentIndex], geometry: geometry)
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
            introductionScene(geometry: geometry)
        case "Park","Classroom","Home":
            TalkingScene(current: current, geometry: geometry)
        case "Chat1", "Chat2", "Chat3":
            chatScene(current: current)
        case "Summary":
            summaryScene(current: current)
        case "Move1":
            moveScene(current: current)
        default:
            defaultScene(current: current)
        }
    }
    
    // MARK: - Introduction Scene
    private func introductionScene(geometry: GeometryProxy) -> some View {
        ZStack {
            CommonUIComponents.backgroundImage("potitama_blackboard")
        }
        .onTapGesture(perform: handleSceneTap)
    }
    
    // MARK: - Talking Scene
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
    // MARK: - Chat Scene
    private func chatScene(current: Dialogue) -> some View {
        let chatDialogues = ChatSceneHelpers.getChatDialoguesFromCurrentIndex(
            dialogues: kakusanDialogues,
            currentIndex: currentIndex,
            chatBackgrounds: chatBackgrounds
        )
        
        return ChatView(
            chatDialogues: chatDialogues,
            onNextScene: {
                ChatSceneHelpers.moveToNextNonChatScene(
                    dialogues: kakusanDialogues,
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
    
    // MARK: - Move Scene
    private func moveScene(current: Dialogue) -> some View {
        ZStack {
            CommonUIComponents.backgroundImage("sky")
        }
        .onTapGesture(perform: handleSceneTap)
    }
    
    // MARK: - Summary Scene
    private func summaryScene(current: Dialogue) -> some View {
        ZStack {
            CommonUIComponents.backgroundImage("sky")
            
            Text(current.dialogueText)
                .font(Font(talkFont))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 600)
                .padding()
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
            
            CommonUIComponents.backToSelectionButton {
                path.removeLast()
            }
        }
        .onTapGesture(perform: handleSceneTap)
    }
    
    // MARK: - Log Overlay
    private func logOverlay(geometry: CGRect) -> some View {
        LogComponents.logOverlay(
            dialogues: kakusanDialogues,
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
extension KakusanView {
    private func handleSceneTap() {
        timer?.invalidate()
        goToNextScene()
    }
    
    private func goToNextScene() {
        currentIndex += 1
        
        if currentIndex < kakusanDialogues.count {
            let currentDialogue = kakusanDialogues[currentIndex]
            
            // Chatシーンでない場合のみタイピングを開始
            if !chatBackgrounds.contains(currentDialogue.background) &&
               !currentDialogue.dialogueText.isEmpty {
                startTyping(fullText: currentDialogue.dialogueText)
            }
        }
    }
    
    private func initializeTyping() {
        if let firstDialogue = kakusanDialogues.first {
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
