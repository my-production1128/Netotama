//
//  GroupchatView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/08/18.
//

import SwiftUI

struct GroupchatView: View {
    // MARK: - State Properties
    @State private var currentIndex = 0
    @State private var isShowingLog = false
    
    // タイピングアニメーション用の状態（TypingRubyLabelRepresentableに任せるため削除）
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
                    onStartTyping: { _ in
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
        // タイマーの停止処理を削除（TypingRubyLabelRepresentableが自動管理）
        goToNextScene()
    }
    
    private func goToNextScene() {
        currentIndex += 1
        // タイピング開始の処理を削除（各シーンで自動的に開始される）
    }
    
    private func startLoopingAnimation() {
        AnimationHelpers.startLoopingAnimation(
            offsetY: $offsetY,
            duration: animationDuration,
            offset: animationOffset
        )
    }
}
