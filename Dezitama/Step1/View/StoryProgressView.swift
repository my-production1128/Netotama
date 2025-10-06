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
    @Binding var path: NavigationPath
    @State private var conversationHistory: [Dialogue2] = []
    @State private var chatSessionId: UUID = UUID()
    
    @State private var viewRefreshKey: UUID = UUID()
    // 会話見返し
    @State private var isChatLogVisible: Bool = false
    // ホームアラート表示
    @State private var isBackMap: Bool = false
    
    @EnvironmentObject private var gameManager: GameManager
    @Binding var currentMode: GameMode

    init(dialogues: [Dialogue2],
         initialSceneId: String = "Scene0",
         currentMode: Binding<GameMode>,
         path: Binding<NavigationPath>) {
        self.dialogues = dialogues
        self._currentSceneId = State(initialValue: initialSceneId)
        self._currentMode = currentMode
        self._path = path
    }
    
    var body: some View {
        GeometryReader { geometry in
            if let currentDialogue = currentDialogue {
                ZStack {
                    // ====== メイン画面 ======
                    switch currentDialogue.viewType {
                    case .dialogue:
                        DialogueView(
                            dialogue: currentDialogue,
                            onNext: handleNavigation
                        )
                    case .chat:
                        ChatMessageView(
                            dialogues: dialogues,
                            initialSceneId: currentSceneId,
                            onNextScene: handleNavigation,
                            path: $path,
                            conversationHistory: $conversationHistory,
                            currentMode: $currentMode
                        )
                        .id(chatSessionId)
                    case .start:
                        startView(dialogue: currentDialogue, onNext: handleNavigation)
                    }
                    
                    // ====== 選択肢オーバーレイ ======
                    if currentDialogue.isChoice == true {
                        BadChoiceView(
                            dialogue: currentDialogue,
                            isPopupVisible: .constant(true),
                            onChoiceSelected: { selectedText, nextId, percentage in
                                if let p = percentage, let v = Double(p) {
                                    gameManager.addScore(percentage: v)
                                }
                                handleNavigation(nextSceneId: nextId)
                            }
                        )
                        .transition(.opacity)
                        .zIndex(100)
                    }
                    
                    // ====== Chatログ表示 ======
                    if isChatLogVisible {
                        ChatLog2View(
                            isChatLogVisible: $isChatLogVisible,
                            conversationHistory: conversationHistory
                        )
                        .zIndex(150)
                    }

                    // ====== 共通UI（ホーム・スコア・ログ） ======
                    VStack {
                        HStack {
                            // ホームボタン
                            VStack {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        isBackMap = true // ← アラート表示
                                    }
                                }) {
                                    Image("home_bad")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                }
                                Spacer()
                            }

                            Spacer()

                            // スコアゲージと会話ログ
                            VStack {
                                HStack {
                                    Spacer()
                                    Gauge(
                                        width: geometry.size.width * 0.3,
                                        height: 100,
                                        score: gameManager.currentScore,
                                        currentMode: $currentMode
                                    )
                                }
                                
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isChatLogVisible.toggle()
                                    }) {
                                        Image("chat")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80)
                                            .padding(20)
                                    }
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .zIndex(50)
                    
                    // ====== HomeAlert（上に重ねる） ======
                    if isBackMap {
                        HomeAlert(path: $path, isBackMap: $isBackMap)
                            .transition(.opacity)
                            .zIndex(200)
                    }
                }
                .id(viewRefreshKey)
                .transition(.opacity)
                .onChange(of: currentSceneId) { oldValue, newValue in
                    if let newDialogue = dialogues.first(where: { $0.sceneId == newValue }) {
                        conversationHistory.append(newDialogue)
                    }
                }
            } else {
                Text("シーンが見つかりません: \(currentSceneId)")
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - 次のシーン取得
    private func getNextDialogue() -> Dialogue2? {
        guard let current = currentDialogue,
              let nextId = current.nextSceneId else {
            return nil
        }
        return dialogues.first(where: { $0.sceneId == nextId })
    }
    
    // MARK: - シーン遷移
    private func handleNavigation(nextSceneId: String) {
        // ストーリー終了処理
        if nextSceneId.lowercased() == "end" {
            print("ストーリー終了")
            let _ = gameManager.scoreToStars(score: gameManager.currentScore)
            
            // MapViewに戻る（全階層削除）
            if !path.isEmpty {
                path.removeLast(path.count)
            }
            return
        }
        
        // 次のシーン取得
        guard let nextDialogue = dialogues.first(where: { $0.sceneId == nextSceneId }) else {
            print("次のシーンが見つかりません: \(nextSceneId)")
            return
        }
        
        // ViewType変化でリフレッシュ
        if currentDialogue?.viewType != nextDialogue.viewType {
            viewRefreshKey = UUID()
        }
        
        currentSceneId = nextSceneId
    }
    
    private var currentDialogue: Dialogue2? {
        dialogues.first(where: { $0.sceneId == currentSceneId })
    }
}

// MARK: - あらすじ画面
struct startView: View {
    let dialogue: Dialogue2
    var onNext: (String) -> Void
    
    var body: some View {
        ZStack {
            // 背景
            Image("arasuzi_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ZStack{
                Image("arasuzi_speechbubble")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 700, height: 300)
                    .offset(y: -150)
                
                // テキスト
                if let dialogueText = dialogue.dialogueText {
                    TypingRubyLabelRepresentable(
                        attributedText: dialogueText
                            .replacingOccurrences(of: "<br>", with: "\n")
                            .createWideRuby(font: UIFont.customFont(ofSize: 30), color: .black),
                        charInterval: 0.05,
                        font: UIFont.customFont(ofSize: 30)
                    )
                    .frame(maxWidth: 500)
                    .padding(.horizontal, 20)
                    .id(dialogueText)
                    .offset(y: -150)
                }
                
                
                // 次へボタン
                Button(action: handleTap) {
                    Image("next_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                }
                .offset(x: 300, y: -90)
            }
                
                
        }
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
