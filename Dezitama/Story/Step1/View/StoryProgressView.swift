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
    @State private var isChatLogVisible: Bool = false
    @State private var isBackMap: Bool = false

    @State private var pendingChoiceDialogue: Dialogue2? = nil // (1) 次に表示する選択肢データを一時保持
    @State private var isChoicePopupVisible: Bool = false      // (2) 選択肢ポップアップの表示フラグ
    @State private var userChoiceReply: Dialogue2? = nil       // (3) ユーザーが選んだセリフを一時表示

        @State private var isEndSceneReady: Bool = false
        @State private var finalThunders: Int = 0
        let stageId: Int

        @EnvironmentObject private var gameManager: GameManager
        @EnvironmentObject var musicplayer: SoundPlayer

        init(dialogues: [Dialogue2],
             initialSceneId: String = "Scene0",
             path: Binding<NavigationPath>,
             stageId: Int) {
            self.dialogues = dialogues
            self._currentSceneId = State(initialValue: initialSceneId)
            self._path = path
            self.stageId = stageId
        }


    
    var body: some View {
        GeometryReader { geometry in
            if let currentDialogue = userChoiceReply ?? self.currentDialogue {
                ZStack {
                    // ====== メイン画面 ======
                    switch currentDialogue.viewType {
//                        会話・まとめ
                        // StoryProgressView.swift (body)

                                            case .dialogue:
                                                DialogueView(
                                                    dialogue: currentDialogue,
                                                    // ▼▼▼ onNextクロージャを修正 ▼▼▼
                                                    onNext: { nextSceneId in
                                                        // (A) もし一時的な返信シーンを表示中なら
                                                        if self.userChoiceReply != nil {
                                                            // 返信シーンが持っている「本当の次のID」を取得
                                                            let realNextId = self.userChoiceReply!.nextSceneId!
                                                            // 返信シーンをクリア
                                                            self.userChoiceReply = nil
                                                            // 本当の次のシーンへ進む
                                                            handleNavigation(nextSceneId: realNextId)
                                                        } else {
                                                            // (B) 通常のシーンなら、そのままhandleNavigationを呼ぶ
                                                            handleNavigation(nextSceneId: nextSceneId)
                                                        }
                                                    }
                                                )
                        // ...
//                        チャット画面
                    case .chat:
                        ChatMessageView(
                            dialogues: dialogues,
                            initialSceneId: currentSceneId,
                            onNextScene: handleNavigation,
                            path: $path,
                            conversationHistory: $conversationHistory
                        )
                        .id(chatSessionId)
                        .environmentObject(gameManager)
//                        あらすじ
                    case .start:
                        startView(dialogue: currentDialogue, onNext: handleNavigation)
                    }
                    
                    // StoryProgressView.swift (body)

                                        // ====== 選択肢オーバーレイ (新) ======
                                        if isChoicePopupVisible, let choiceDialogue = pendingChoiceDialogue {
                                            BadChoiceView(
                                                dialogue: choiceDialogue,
                                                isPopupVisible: $isChoicePopupVisible, // .constant(true) から $isChoicePopupVisible に変更
                                                onChoiceSelected: { selectedText, nextId, percentage in

                                                    // 1. ユーザーが選んだセリフを一時的に表示するシーンを作成
                                                    // (ChatMessageViewやStoryBranchViewと同様のロジック)
                                                    let replyScene = Dialogue2(
                                                        storyId: choiceDialogue.storyId,
                                                        sceneId: "user_reply_\(UUID())", // 一意のID
                                                        viewType: .dialogue,
                                                        characterName: "コニー", // ユーザー
                                                        dialogueText: selectedText,
                                                        nextSceneId: nextId, // タップしたら次に進むID
                                                        isChoice: false,
                                                        // 背景やキャラクターは、選択肢シーンのものを引き継ぐ
                                                        background: choiceDialogue.background,
                                                        talkingPeople: choiceDialogue.talkingPeople,
                                                        leftCharacter: choiceDialogue.leftCharacter,
                                                        centerCharacter: choiceDialogue.centerCharacter,
                                                        rightCharacter: choiceDialogue.rightCharacter,
                                                        oneCharacter: choiceDialogue.oneCharacter,
                                                        twoCharacter: choiceDialogue.twoCharacter,
                                                        onePerson: choiceDialogue.onePerson,
                                                        bgm: choiceDialogue.bgm
                                                    )

                                                    // 2. Stateを更新
                                                    self.userChoiceReply = replyScene     // 一時的な返信シーンをセット
                                                    self.isChoicePopupVisible = false   // ポップアップを閉じる
                                                    self.pendingChoiceDialogue = nil  // 待機中の選択肢をクリア
                                                }
                                            )
                                            .transition(.opacity)
                                            .zIndex(100) // 念のため一番上に
                                        }
                    // ...

                    // ====== Chatログ表示 ======
                    if isChatLogVisible {
                        ChatLog2View(
                            isChatLogVisible: $isChatLogVisible,
                            conversationHistory: conversationHistory
                        )
                    }

                    // ====== 共通UI（ホーム・スコア・ログ） ======
                    VStack {
                        HStack {
                            // ホームボタン
                            VStack {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        isBackMap = true
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
                                        score: gameManager.currentScore
                                    )
                                    .environmentObject(gameManager)
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

                    // ====== HomeAlert（上に重ねる） ======
                    if isBackMap {
                        HomeAlert(path: $path, isBackMap: $isBackMap)
                            .transition(.opacity)
                    }

                    if isEndSceneReady {
                        finalThundersView(
                            finalThunders: self.finalThunders,
                            path: $path
                        )
                        .environmentObject(musicplayer)
                    }
                }
                .id(viewRefreshKey)
                .transition(.opacity)
                .onChange(of: currentSceneId) { oldValue, newValue in
                    if let newDialogue = dialogues.first(where: { $0.sceneId == newValue }) {
                        conversationHistory.append(newDialogue)
                    }
                }
                .onAppear {
                    gameManager.startStory(dialogues: dialogues)
                }
            } else {
                Text("シーンが見つかりません: \(currentSceneId)")
                    .foregroundColor(.red)
            }
        }
        .background {
            if let currentDialogue = currentDialogue{
                Image(currentDialogue.background ?? "背景が設定されていません")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
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

            // 既に終了処理済みなら何もしない
            if isEndSceneReady {
                return
            }

            // 1. スコアを雷の数（0〜3）に変換
            let thunders = gameManager.scoreToStars(score: gameManager.currentScore)
            self.finalThunders = thunders

            // 2. GameManager にスコアを保存
            gameManager.completeStage(
                stageId: self.stageId,
                mode: self.gameManager.currentMode,
                earnedScore: thunders
            )

            // 3. 結果画面を表示
            isEndSceneReady = true

            return
        }

        // 次のシーン取得
        guard let nextDialogue = dialogues.first(where: { $0.sceneId == nextSceneId }) else {
            print("次のシーンが見つかりません: \(nextSceneId)")
            return
        }

        if nextDialogue.isChoice == true {
                    // 画面遷移せず、ポップアップの準備をする
                    self.pendingChoiceDialogue = nextDialogue
                    self.isChoicePopupVisible = true
                    return // ★ここで処理を中断★
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


