//
//  StoryProgressView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/10/01.
//

import SwiftUI

struct StoryProgressView: View {
    let dialogues: [Dialogue2]
    @State private var currentSceneId: String
    @State private var path = NavigationPath()
    @State private var conversationHistory: [Dialogue2] = []
    
    // ★ チャットセッションを管理
    @State private var chatSessionId: UUID = UUID()
    @State private var isInChatSession: Bool = false
    
    @EnvironmentObject private var gameManager: GameManager
    
    init(dialogues: [Dialogue2], initialSceneId: String = "Scene0") {
        self.dialogues = dialogues
        self._currentSceneId = State(initialValue: initialSceneId)
    }
    
    var body: some View {
        if let currentDialogue = currentDialogue {
            ZStack {
                // ====== メインの画面 ======
                switch currentDialogue.viewType {
                case .dialogue:
                    DialogueView(dialogue: currentDialogue, onNext: handleNavigation)
                case .chat:
                    ChatMessageView(
                        dialogues: dialogues,
                        initialSceneId: currentSceneId,
                        onNextScene: handleNavigation,
                        path: $path,
                        conversationHistory: $conversationHistory
                    )
                    .id(chatSessionId)
                case .start:
                    startView(dialogue: currentDialogue, onNext: handleNavigation)
                }
                
                // ====== Choice のオーバーレイ ======
                // isChoiceがtrueの場合にBadChoiceViewを重ねて表示
//                if currentDialogue.isChoice == true {
//                    BadChoiceView(dialogue: currentDialogue, onChoice: handleNavigation)
//                        .transition(.opacity)
//                        .zIndex(10) // 最前面
//                }
            }
            .onChange(of: currentSceneId) { oldValue, newValue in
                if let newDialogue = dialogues.first(where: { $0.sceneId == newValue }) {
                    conversationHistory.append(newDialogue)
                }
            }
        }
    }
    
    private func handleNavigation(nextSceneId: String) {
        guard let nextDialogue = dialogues.first(where: { $0.sceneId == nextSceneId }) else {
            return
        }
        
        if currentDialogue?.viewType == .chat && nextDialogue.viewType == .chat {
            currentSceneId = nextSceneId
        } else if nextDialogue.viewType == .chat {
            isInChatSession = true
            currentSceneId = nextSceneId
        } else {
            if currentDialogue?.viewType == .chat {
                isInChatSession = false
                chatSessionId = UUID()
            }
            currentSceneId = nextSceneId
        }
    }
    
    private var currentDialogue: Dialogue2? {
        dialogues.first(where: { $0.sceneId == currentSceneId })
    }
}


struct startView: View {
    let dialogue: Dialogue2
    var onNext: (String) -> Void
    
    var body: some View {
        ZStack {
            // 背景
            Image("sky")
                .resizable()
                .scaledToFill()
            
            VStack(spacing: 40) {
                Spacer()
                
                // dialogueTextの表示
                if let dialogueText = dialogue.dialogueText {
                    TypingRubyLabelRepresentable(
                        attributedText: dialogueText
                            .replacingOccurrences(of: "<br>", with: "\n")
                            .createWideRuby(font: UIFont.customFont(ofSize: 30), color: .black),
                        charInterval: 0.05,
                        font: UIFont.customFont(ofSize: 30)
                    )
                    .frame(maxWidth: 700)
                    .padding(.horizontal, 20)
                    .id(dialogueText)
                }
                
                Spacer()
                
                // 次へボタン
                Button(action: handleTap) {
                    Image("next_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                }
                .padding(.bottom, 40)
            }
        }
        // 画面全体をタップ可能にする
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
    }
    
    private func handleTap() {
        if let nextSceneId = dialogue.nextSceneId {
            onNext(nextSceneId)
        }
    }
}
