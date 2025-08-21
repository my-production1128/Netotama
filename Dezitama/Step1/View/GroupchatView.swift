//
//  GroupchatView.swift
//  Dezitama
//
//  Refactored to use CommonUIComponents
//

import SwiftUI

struct GroupchatView: View {
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
    @Binding var groupchatDialogues: [Dialogue]
    
    // MARK: - Constants
    private let talkFont = UIFont.customFont(ofSize: 30)
    private let charaNameFont = UIFont.customFont(ofSize: 35)
    private let typingInterval: TimeInterval = 0.05
    private let animationDuration: Double = 0.6
    private let animationOffset: CGFloat = 8.0
    private let chatBackgrounds = ["Chat"]
    private let rightCharacterName = "セシル"

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            Group {
                if currentIndex < groupchatDialogues.count {
                    sceneView(for: groupchatDialogues[currentIndex], geometry: geometry)
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
        case "Classroom":
            classroomScene(current: current, geometry: geometry)
        case "Chat":
            chatScene(current: current)
        case "Summary":
            summaryScene(current: current)
        default:
            defaultScene(current: current)
        }
    }
    
    // MARK: - Introduction Scene
    private func introductionScene(geometry: GeometryProxy) -> some View {
        ZStack {
            CommonUIComponents.backgroundImage("gurutama_blackboard")
        }
        .onTapGesture(perform: handleSceneTap)
    }
    
    // MARK: - Classroom Scene (Using TalkingView)
    private func classroomScene(current: Dialogue, geometry: GeometryProxy) -> some View {
        ZStack {
            // TalkingViewコンポーネントを使用
            TalkingView(
                current: current,
                geometry: geometry,
                displayedText: $displayedText,
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
            dialogues: groupchatDialogues,
            currentIndex: currentIndex,
            chatBackgrounds: chatBackgrounds
        )
        
        return ChatView(
            chatDialogues: chatDialogues,
            onNextScene: {
                ChatSceneHelpers.moveToNextNonChatScene(
                    dialogues: groupchatDialogues,
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
    
    // MARK: - Log Overlay
    private func logOverlay(geometry: CGRect) -> some View {
        LogComponents.logOverlay(
            dialogues: groupchatDialogues,
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
extension GroupchatView {
    private func handleSceneTap() {
        timer?.invalidate()
        goToNextScene()
    }
    
    private func goToNextScene() {
        currentIndex += 1
        
        if currentIndex < groupchatDialogues.count {
            let currentDialogue = groupchatDialogues[currentIndex]
            
            // Chatシーンでない場合のみタイピングを開始
            if !chatBackgrounds.contains(currentDialogue.background) &&
               !currentDialogue.dialogueText.isEmpty {
                startTyping(fullText: currentDialogue.dialogueText)
            }
        }
    }
    
    private func initializeTyping() {
        if let firstDialogue = groupchatDialogues.first {
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

    private func getCharacterIcon(for characterName: String) -> String {
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
        default: return "default_icon"
        }
    }
}
