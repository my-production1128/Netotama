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
    
    // ★ ビュー再描画用のキー
    @State private var viewRefreshKey: UUID = UUID()
    
    @EnvironmentObject private var gameManager: GameManager
    
    init(dialogues: [Dialogue2], initialSceneId: String = "Scene0") {
        self.dialogues = dialogues
        self._currentSceneId = State(initialValue: initialSceneId)
    }
    
    var body: some View {
        Group {
            if let currentDialogue = currentDialogue {
                ZStack {
                    // ====== メインの画面 ======
                    switch currentDialogue.viewType {
                    case .dialogue:
                            DialogueView(
                                dialogue: currentDialogue,
                                nextDialogue: getNextDialogue(), // ★ 追加
                                onNext: handleNavigation
                                        )
                    case .chat:
                        ChatMessageView(
                            dialogues: dialogues,
                            initialSceneId: currentSceneId,
                            onNextScene: handleNavigation,
                            path: $path,
                            conversationHistory: $conversationHistory
                        )
                    case .start:
                        startView(dialogue: currentDialogue, onNext: handleNavigation)
                    }
                }
                .id(viewRefreshKey) // すべてのビューに共通のキーを適用
                .transition(.opacity) // スムーズな遷移
            } else {
                Text("シーンが見つかりません: \(currentSceneId)")
                    .foregroundColor(.red)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewRefreshKey)
        .onChange(of: currentSceneId) { oldValue, newValue in
            if let newDialogue = dialogues.first(where: { $0.sceneId == newValue }) {
                conversationHistory.append(newDialogue)
            }
        }
    }
    
    private func getNextDialogue() -> Dialogue2? {
        guard let current = currentDialogue,
              let nextId = current.nextSceneId else {
            return nil
        }
        return dialogues.first(where: { $0.sceneId == nextId })
    }
    
    private func handleNavigation(nextSceneId: String) {
        guard let nextDialogue = dialogues.first(where: { $0.sceneId == nextSceneId }) else {
            return
        }
        
        let currentViewType = currentDialogue?.viewType
        let nextViewType = nextDialogue.viewType
        
        // すべての遷移パターンに対応
        // viewTypeが変わる場合は必ず新しいキーを生成して完全に再描画
        if currentViewType != nextViewType {
            viewRefreshKey = UUID()
        }
        
        // シーンIDを更新（常に実行）
        currentSceneId = nextSceneId
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
                .ignoresSafeArea()
            
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
        print("startView tapped, nextSceneId: \(dialogue.nextSceneId ?? "nil")")
        if let nextSceneId = dialogue.nextSceneId {
            onNext(nextSceneId)
        }
    }
}
