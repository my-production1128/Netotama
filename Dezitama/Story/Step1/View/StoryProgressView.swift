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

    @State private var pendingChoiceDialogue: Dialogue2? = nil
    @State private var isChoicePopupVisible: Bool = false
    @State private var userChoiceReply: Dialogue2? = nil

    @State private var isEndSceneReady: Bool = false
    @State private var showResultButton: Bool = false
    @State private var finalThunders: Int = 0

    @State private var screenTextOffset: CGFloat = 0.0

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
                    switch currentDialogue.viewType {

                    case .dialogue:
                        DialogueView(
                            dialogue: currentDialogue,
                            onNext: { nextSceneId in
                                if self.userChoiceReply != nil {
                                    let realNextId = self.userChoiceReply!.nextSceneId!
                                    self.userChoiceReply = nil
                                    handleNavigation(nextSceneId: realNextId)
                                } else {
                                    handleNavigation(nextSceneId: nextSceneId)
                                }
                            }
                        )

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

                    case .screen:
                        ZStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)

                            Text(currentDialogue.dialogueText ?? "")
                                .font(.custom("MPLUS1-Regular", size: 45))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .offset(x: screenTextOffset)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .contentShape(Rectangle())
                        .onAppear {
                            if let bgm = currentDialogue.bgm, !bgm.isEmpty {
                                                            musicplayer.stopAllMusic()
                                                            musicplayer.playBGM(fileName: bgm)
                                                        }
                            let totalDuration: TimeInterval = 3.0
                            let moveInDuration: TimeInterval = 0.8
                            let waitDuration: TimeInterval = 1.4
                            let moveOutDuration: TimeInterval = totalDuration - moveInDuration - waitDuration

                            let startOffset = -geometry.size.width
                            screenTextOffset = startOffset

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: moveInDuration)) {
                                    screenTextOffset = 0
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 + moveInDuration + waitDuration) {
                                let endOffset = geometry.size.width
                                withAnimation(.easeIn(duration: moveOutDuration)) {
                                    screenTextOffset = endOffset
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
                                guard currentDialogue.viewType == .screen else {
                                    print("Scene changed before 3s timer. Aborting automatic 'screen' transition.")
                                    return
                                }
                                guard let nextId = currentDialogue.nextSceneId, !nextId.isEmpty else {
                                    print("🚨 Error: 'screen' scene has no valid nextSceneId.")
                                    handleNavigation(nextSceneId: "end")
                                    return
                                }
                                handleNavigation(nextSceneId: nextId)
                            }
                        }

                        //                        あらすじ
                    case .start:
                        startView(dialogue: currentDialogue, onNext: handleNavigation)
                    }

                    // StoryProgressView.swift (body)


                    if isChoicePopupVisible, let choiceDialogue = pendingChoiceDialogue {
                        BadChoiceView(
                            dialogue: choiceDialogue,
                            isPopupVisible: $isChoicePopupVisible,
                            onChoiceSelected: { selectedText, nextId, percentage in
                                let replyScene = Dialogue2(
                                    storyId: choiceDialogue.storyId,
                                    sceneId: "user_reply_\(UUID())", // 一意のID
                                    viewType: .dialogue,
                                    characterName: "コニー", // ユーザー
                                    dialogueText: selectedText,
                                    nextSceneId: nextId, // タップしたら次に進むID
                                    isChoice: false,
                                    background: choiceDialogue.background,
                                    talkingPeople: choiceDialogue.talkingPeople,
                                    leftCharacter: choiceDialogue.leftCharacter,
                                    centerCharacter: choiceDialogue.centerCharacter,
                                    rightCharacter: choiceDialogue.rightCharacter,
                                    oneCharacter: choiceDialogue.oneCharacter,
                                    twoCharacter: choiceDialogue.twoCharacter,
                                    onePerson: choiceDialogue.onePerson,
                                    bgm: choiceDialogue.bgm,
                                    groupName: choiceDialogue.groupName
                                )

                                print("履歴追加 (BadChoiceView): \(replyScene.sceneId) - \(replyScene.dialogueText ?? "")")
                                conversationHistory.append(replyScene)
                                // 2. Stateを更新
                                self.userChoiceReply = replyScene     // 一時的な返信シーンをセット
                                self.isChoicePopupVisible = false   // ポップアップを閉じる
                                self.pendingChoiceDialogue = nil  // 待機中の選択肢をクリア
                            }
                        )
                        .transition(.opacity)
                        //                        .zIndex(100)
                    }
                    // ...

                    // ====== 共通UI（ホーム・スコア・ログ） ======
                    VStack {
                        HStack {
                            // ホームボタン
                            VStack {
                                Button(action: {
                                    musicplayer.playSE(fileName: "button_SE")
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

                    if showResultButton {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                Button {
                                    print("成績ボタンが押されました。結果を表示します。")
                                    // ★ スコア計算と保存をここで行う ★
                                    if !isEndSceneReady { // まだ計算・保存してなければ
                                        let thunders = gameManager.scoreToStars(score: gameManager.currentScore)
                                        self.finalThunders = thunders
                                        gameManager.completeStage(stageId: self.stageId, mode: gameManager.currentMode, earnedScore: thunders)
                                        isEndSceneReady = true // 結果画面表示フラグを立てる
                                    }
                                } label: {
                                    Image("good_seiseki")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250, height: 250)
                                    //                                    .padding(.trailing, 30)
                                }
                                .offset(x: 0, y: 40)
                            }
                        }
                    }

                    // ====== Chatログ表示 ======
                    if isChatLogVisible {
                        ChatLog2View(
                            isChatLogVisible: $isChatLogVisible,
                            conversationHistory: conversationHistory
                        )
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
                .onChange(of: currentSceneId) { _, newSceneId in

                    // ★ 最後のシーンかどうかのチェック ★
                    guard let newDialogue = dialogues.first(where: { $0.sceneId == newSceneId }) else {
                        return
                    }

                    // (A) もし、新しく表示するこのシーンの「次」が "end" なら
                    if newDialogue.nextSceneId?.lowercased() == "end" {
                        // ...そして、まだボタンが表示されていなければ
                        if !showResultButton && !isEndSceneReady {
                            print("最後のシーン (\(newSceneId)) に到達しました。成績ボタンを表示します。")

                            // ★ 成績ボタンを表示する
                            // (少し遅延させて、シーン切り替えのアニメーションと被らないようにします)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showResultButton = true
//                            }
                        }
                    }
                    // (B) もし、次のシーンが "end" でないなら
                    else {
                        // (履歴を戻った場合などを考慮し、ボタンが表示されていれば非表示に戻します)
                        if showResultButton {
                            self.showResultButton = false
                        }
                    }
                }
                //                .onChange(of: currentSceneId) { oldValue, newValue in
                //                    if let newDialogue = dialogues.first(where: { $0.sceneId == newValue }) {
                //                        conversationHistory.append(newDialogue)
                //                    }
                //                }
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
            print("ストーリー終了 (handleNavigation)") // ログを分かりやすく変更

            // 既に終了処理済みか、ボタン表示済みなら何もしない
            if isEndSceneReady || showResultButton {
                print("既に終了/ボタン表示済みです。")
                return
            }

            // ★「成績ボタン」を表示するフラグを立てる
            // (主にChatMessageViewがendを返した時用)
            showResultButton = true
            print("成績ボタンを表示します。")

            return // シーン遷移はここでストップ
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

        if nextDialogue.viewType == .dialogue {
            // 履歴にまだ同じIDがなければ追加 (念のため)
            if !conversationHistory.contains(where: { $0.id == nextDialogue.id }) {
                print("履歴追加 (handleNavigation - New Scene): \(nextDialogue.sceneId) - \(nextDialogue.dialogueText ?? "テキストなし")")
                conversationHistory.append(nextDialogue)
            }
        }
    }

//    private func checkIfLastScene(sceneId: String) {
//            guard let scene = branchingMap[sceneId] else { return }
//
//            // 最後のシーン (nextSceneId が "end") かつ、
//            // まだ結果表示前で、成績ボタンも表示されていなければ
//            if scene.nextSceneId.lowercased() == "end" && !isEndSceneReady && !showResultButton {
//
//                // talk シーンの場合はタイピング完了を待つ
//                if scene.sceneType == "talk" {
//                    if isTypingComplete { // タイピングが終わっていたら表示
//                        print("最後の talk シーンのタイピング完了。成績ボタンを表示します。")
//                        // 少しだけ遅延させて表示 (アニメーションと重ならないように)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                             showResultButton = true
//                        }
//                    } else {
//                        print("最後の talk シーンですが、タイピング中のためボタンはまだ表示しません。")
//                    }
//                } else { // talk 以外はそのシーンが表示されたらすぐにボタン表示
//                    print("最後のシーン (\(scene.sceneType)) です。成績ボタンを表示します。")
//                     // 少しだけ遅延させて表示 (シーン遷移アニメーションと重ならないように)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                         showResultButton = true
//                    }
//                }
//            } else if scene.nextSceneId.lowercased() != "end" && showResultButton {
//                // もし何らかの理由でボタンが表示されたまま次のシーンに進んだら非表示にする
//                showResultButton = false
//            }
//        }

    private var currentDialogue: Dialogue2? {
        dialogues.first(where: { $0.sceneId == currentSceneId })
    }
}
