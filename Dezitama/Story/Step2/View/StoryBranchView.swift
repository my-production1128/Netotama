//
//  NetomoBranchingView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/06/06.
//

import Lottie
import SwiftUI

struct StoryBranchView: View {
    @State private var currentSceneId: String = ""
    @State private var historyStack: [String] = []
    @State private var showSpecialView: Bool = false
    @State private var offsetY: CGFloat = 0.0
    @State var isPopupVisible: Bool = false
    @State var nextChat: Bool = false


    @State private var displayedText = ""
    @State private var currentCharIndex = 0
    @State private var timer: Timer? = nil

    @State private var isTypingComplete: Bool = false
    @State private var shouldSkipTyping: Bool = false


    // 選択肢のシーンを一時的に保持する新しいState変数
    @State private var currentChoiceScene: Branching? = nil

    //    会話の見返しボタン用関数
    @State var isChatLogVisible: Bool = false
    @State private var conversationHistory: [Branching] = []

    //    ストーリーが終了した場合セリフを最後まで読んだあとにタップしたか判別する
    @State var isEndSceneReady: Bool = false

    @State private var finalStars: Int = 0
    @State var isBackMap: Bool = false

    let stageId: Int
    let mode: GameMode

    //    選択肢のポイント用
    @EnvironmentObject private var gameManager: GameManager
    @EnvironmentObject var musicplayer: SoundPlayer


    let talkFont = UIFont.customFont(ofSize: 30)
    let charaNameFont = UIFont.customFont(ofSize: 35)

    @Binding var path: NavigationPath
    @Binding var allBranchings: [Branching]
    @Binding var allScene: Branching
    @Binding var currentMode: GameMode

    let StoryId: String
    // 表示に必要なデータだけを、allBranchingsからリアルタイムで絞り込む
    private var currentStoryBranchings: [Branching] {
        return allBranchings.filter { $0.storyId == StoryId }
    }

    private var branchingMap: [String: Branching] {
        var map: [String: Branching] = [:]
        for b in currentStoryBranchings {
            if map[b.sceneId] == nil {
                map[b.sceneId] = b
            } else {
                print("⚠️ Duplicate sceneId found in the same story: \(b.sceneId)")
            }
        }
        return map
    }

    init(path: Binding<NavigationPath>,
         allBranchings: Binding<[Branching]>,
         allScene: Binding<Branching>,
         StoryId: String, stageId: Int,
         mode: GameMode,
         currentMode: Binding<GameMode>) {
        self._path = path
        self._allBranchings = allBranchings
        self._allScene = allScene
        self.StoryId = StoryId
        self.stageId = stageId
        self.mode = mode
        self._currentMode = currentMode
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let sceneToDisplay = currentChoiceScene ?? branchingMap[currentSceneId]
                if let current = sceneToDisplay {
                    VStack {
                        Spacer()
                        switch current.sceneType {
                        case "screen":
                            ZStack {
                                HStack {
                                    Image("next_button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35)
                                        .position(x: geometry.size.width * 0.85,y: geometry.size.height * 0.905)
                                        .offset(y: offsetY)
                                        .onAppear {
                                            startLoopingAnimation()
                                        }
                                }
                                Text(current.text)
                                    .font(.custom("MPLUS1-Regular", size: 35))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if current.nextSceneId.lowercased() == "end" {
                                    if !isEndSceneReady {
                                        let stars = gameManager.scoreToStars(score: gameManager.currentScore)
                                        self.finalStars = stars
                                        gameManager.completeStage(stageId: self.stageId, mode: self.mode, earnedScore: stars)
                                        isEndSceneReady = true
                                    }
                                    return // ここで処理を終了
                                }

                                // 2. "end" でなければ、これまで通りの処理を続けます
                                guard let nextScene = branchingMap[current.nextSceneId] else {
                                    return
                                }

                                if nextScene.isChoice == true {
                                    isPopupVisible = true
                                    currentChoiceScene = nextScene
                                } else {
                                    currentSceneId = nextScene.sceneId
                                }
                            }
                            .onAppear {
                                if let current = sceneToDisplay {
                                    musicplayer.stopAllMusic()
                                    musicplayer.playBGM(fileName: current.bgm)
                                }
                            }


                        case "chat", "chat_picture":
                            ChatSceneView(
                                branchingMap: branchingMap,
                                initialSceneId: currentSceneId,
                                onNextScene: { nextId in
                                    if nextId == "end" {
                                        if !isEndSceneReady {
                                            let stars = gameManager.scoreToStars(score: gameManager.currentScore)
                                            self.finalStars = stars
                                            gameManager.completeStage(stageId: self.stageId, mode: self.mode, earnedScore: stars)
                                            isEndSceneReady = true
                                        }
                                    } else {
                                        historyStack.append(currentSceneId)
                                        currentSceneId = nextId
                                    }
                                },
                                width: geometry.size.width,
                                height: geometry.size.height,
                                allBranchings: $allBranchings,
                                allScene: $allScene,
                                isPopupVisible: $isPopupVisible,
                                conversationHistory: $conversationHistory,
                                isEndSceneReady: $isEndSceneReady
                            )
                            .onAppear {
                                musicplayer.stopAllMusic()
                                musicplayer.playBGM(fileName: current.bgm)
                            }
                            .ignoresSafeArea()

                        case "talk_AE":
                            ZStack {
                                LottieView(name: current.text, loopMode: .playOnce)
                                    .edgesIgnoringSafeArea(.all)
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        guard let nextScene = branchingMap[current.nextSceneId] else {
                                            if current.nextSceneId == "end" || current.nextSceneId.isEmpty {
                                                gameManager.completeStage(stageId: self.stageId, mode: self.mode, earnedScore: 0)
                                                isEndSceneReady = true
                                            }
                                            return
                                        }
                                        if nextScene.isChoice == true {
                                            isPopupVisible = true
                                            currentChoiceScene = nextScene
                                        } else {
                                            currentSceneId = nextScene.sceneId
                                        }
                                    }
                                HStack {
                                    Image("next_button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35)
                                        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.905)
                                        .offset(y: offsetY)
                                        .onAppear {
                                            startLoopingAnimation()
                                        }
                                }
                                .allowsHitTesting(false)
                            }
                            .onAppear {
                                if let current = sceneToDisplay {
                                    musicplayer.stopAllMusic()
                                    musicplayer.playBGM(fileName: current.bgm)
                                }
                            }

                        case "talk":
                            ZStack {
                                HStack(spacing: 0) {
                                    if !current.leftCharacter.isEmpty {
                                        if current.centerCharacter.isEmpty && current.rightCharacter.isEmpty {
                                            Spacer()
                                        }

                                        // 左のキャラクター画像
                                        Image(current.leftCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 350, height: 500)
                                            // 💡 非発言時はグレーアウトなどの修飾子をここに適用できる
                                            // .opacity(current.characterName == current.leftCharacter ? 1.0 : 0.7)
                                    }

                                    // 2. 中央のキャラクター (左・右どちらかが存在する場合、中央は自動で中央に寄る)
                                    if !current.centerCharacter.isEmpty {
                                        // 中央のみ表示の場合、Spacerで両端を挟む
                                        if current.leftCharacter.isEmpty && current.rightCharacter.isEmpty {
                                            Spacer()
                                        }

                                        // 中央のキャラクター画像
                                        Image(current.centerCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 350, height: 500)
                                            // 💡 非発言時はグレーアウト
                                            // .opacity(current.characterName == current.centerCharacter ? 1.0 : 0.7)

                                        if current.leftCharacter.isEmpty && current.rightCharacter.isEmpty {
                                            Spacer()
                                        }
                                    }

                                    // 3. 右のキャラクター
                                    if !current.rightCharacter.isEmpty {
                                        // 右側が空いている場合にSpacerを追加
                                        if current.leftCharacter.isEmpty && current.centerCharacter.isEmpty {
                                            Spacer() // 左と中央が空なら右寄せではないためSpacerが必要
                                        }

                                        // 右のキャラクター画像
                                        Image(current.rightCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 350, height: 500)
                                            // 💡 非発言時はグレーアウト
                                            // .opacity(current.characterName == current.rightCharacter ? 1.0 : 0.7)
                                    }

                                    // 4. 左・中央・右のすべてが表示されていない場合
                                    if current.leftCharacter.isEmpty && current.centerCharacter.isEmpty && current.rightCharacter.isEmpty {
                                        Text("キャラクターが設定されていません")
                                    }
                                }
                                .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.5)
                                // .position の代わりに .frame(maxWidth: .infinity) を使用し、HStack内のSpacerに任せる
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                                Group{
                                    //                                     吹き出し背景
                                    Image("speech_bubble_beige")
                                        .resizable()
                                        .frame(width: 950, height: 250)
                                        .offset(x:-13, y: 0)
                                        .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.8)

                                    //                                     キャラ名ラベル
                                    let characterNameText = CharacterName(rawValue: current.characterName)?.displayName ?? current.characterName
                                    Text(characterNameText)
                                        .font(.custom("MPLUS1-Regular", size: 35))
                                        .font(.title)
                                        .padding(6)
                                        .cornerRadius(8)
                                        .position(x: geometry.size.width * 0.22,y: geometry.size.height * 0.677)

                                    //                                    テキスト（会話文）
                                    TypingRubyLabelRepresentable(
                                        // createWideRuby に font を渡す
                                        attributedText: current.text
                                            .replacingOccurrences(of: "<br>", with: "\n")
                                            .createWideRuby(font: talkFont, color: .black), // ← 修正
                                        charInterval: 0.05,
                                        // こちらにも同じ font を渡す
                                        font: talkFont,
                                        targetWidth: 500
                                    )
                                    .fixedSize(horizontal: false, vertical: true) // UILabelのサイズ計算を尊重させる
                                    .frame(maxWidth: 700)
                                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)

                                    //                                     ナビゲーション
                                    HStack {
                                        Image("next_button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 35)
                                            .position(x: geometry.size.width * 0.85,y: geometry.size.height * 0.905)
                                            .offset(y: offsetY)
                                            .onAppear {
                                                startLoopingAnimation()
                                            }
                                    }
                                }
                                .offset(y: 20)
                            }
                            .onAppear {
                                let sceneToDisplay = currentChoiceScene ?? branchingMap[currentSceneId]
                                if let current = sceneToDisplay {
                                    musicplayer.stopAllMusic()
                                    musicplayer.playBGM(fileName: current.bgm)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // ポップアップ表示中はタップを無効にする
                                if isPopupVisible {
                                    return
                                }

                                if let replyScene = currentChoiceScene {
                                    let nextActualId = replyScene.nextSceneId
                                    self.currentChoiceScene = nil // 一時シーンをクリア
                                    self.currentSceneId = nextActualId
                                    return
                                }

                                print("--- 🔵 talkシーンがタップされました ---")
                                print("文字の表示完了フラグ (isTypingComplete): \(isTypingComplete)")

                                if !isTypingComplete {
                                    shouldSkipTyping = true
                                    isTypingComplete = true
                                    print("文字表示をスキップします。")
                                } else {
                                    guard let current = branchingMap[currentSceneId] else {
                                        print("🚨【エラー】現在のシーンID「\(currentSceneId)」がマップ内に見つかりません。")
                                        return
                                    }

                                    let nextId = current.nextSceneId
                                    print("次のシーンID「\(nextId)」へ進もうとしています。")

                                    guard let nextScene = branchingMap[nextId] else {
                                        if nextId.lowercased() == "end" || nextId.isEmpty {
                                            print("物語の終点です。終了処理を開始します。")
                                            if !isEndSceneReady {
                                                let stars = gameManager.scoreToStars(score: gameManager.currentScore)
                                                self.finalStars = stars
                                                gameManager.completeStage(stageId: self.stageId, mode: self.mode, earnedScore: stars)
                                                isEndSceneReady = true
                                            }
                                        } else {
                                            print("🚨【エラー】次のシーンID「\(nextId)」がマップ内に見つかりません。CSVのIDが正しいか確認してください。")
                                        }
                                        return
                                    }

                                    print("✅ 次のシーン「\(nextId)」が見つかりました。タイプは「\(nextScene.sceneType)」です。")

                                    historyStack.append(currentSceneId)
                                    if nextScene.isChoice != true {
                                        conversationHistory.append(nextScene)
                                    }

                                    if nextScene.sceneType.lowercased() == "talk" {
                                        print("➡️ 次も talk シーンです。")
                                        if nextScene.isChoice == true {
                                            print("選択肢なのでポップアップを表示します。")
                                            isPopupVisible = true
                                            currentChoiceScene = nextScene
                                        } else {
                                            print("通常のtalkシーンなので、IDを「\(nextScene.sceneId)」に更新します。")
                                            currentSceneId = nextScene.sceneId
                                        }
                                    } else {
                                        print("➡️ talk 以外のシーン（\(nextScene.sceneType)）に切り替わります。")
                                        print("IDを「\(nextScene.sceneId)」に更新します。")
                                        currentSceneId = nextScene.sceneId
                                    }
                                }
                                print("-------------------------------------\n")
                            }

                        default:
                            Text("このscemneTypeは未対応です")
                        }
                    }
                } else {
                    Text("ストーリーが読み込めませんでした")
                }


                if isPopupVisible, let choiceScene = currentChoiceScene {
                    isChoiceView(
                        isPopupVisible: $isPopupVisible,
                        allScene: .constant(choiceScene),
                        onChoiceSelected: { selectedText, nextId in

                            // 1. ユーザーの選択を会話履歴に追加するためのデータを作成します
                            let userChoiceScene = Branching(
                                storyId: choiceScene.storyId,
                                sceneId: choiceScene.sceneId,
                                sceneType: "talk", // talkシーンの選択なのでtalk
                                groupName: choiceScene.groupName,
                                icon: choiceScene.icon,
                                characterName: choiceScene.rightCharacter,
                                leftCharacter: choiceScene.leftCharacter,
                                centerCharacter: choiceScene.centerCharacter,
                                rightCharacter: choiceScene.rightCharacter,
                                text: selectedText,
                                nextSceneId: nextId,
                                isChoice: false,
                                choice1Text: "",
                                choice1Percentage: nil,
                                choice1NextSceneId: "",
                                choice2Text: "",
                                choice2Percentage: nil,
                                choice2NextSceneId: "",
                                choice3Text: "",
                                choice3Percentage: nil,
                                choice3NextSceneId: "",
                                bgm: choiceScene.bgm,
                                background: choiceScene.background
                            )

                            // 2. 作成したデータを会話履歴（見返し機能用）に追加します
                            conversationHistory.append(userChoiceScene)

                            // 3. 選択肢で決まった次のシーンIDに画面を遷移させます（これが一番重要！）
                            self.currentChoiceScene = userChoiceScene
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isPopupVisible = false
                            }
                        }
                    )
                }

                HStack {
                    VStack {
//                        ホームボタン
                        Button {
                            isBackMap = true
                        }label: {
                            Image("home_good")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .padding(.top, 0)
                        }
                            Spacer()
                    }
                    Spacer()
                    VStack {
                        Gauge(width: geometry.size.width * 0.3, height: 100,
                              score: gameManager.currentScore,
                              currentMode: $currentMode)
                        .padding(.trailing,2)
                        //                        会話見返し機能
                        Button(action: {
                            musicplayer.playSE(fileName: "button_SE")
                            isChatLogVisible.toggle()
                        }) {
                            Image("chat") // chatボタンを流用
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
//                                .padding()
                        }
                        .zIndex(0)
                        Spacer()
                    }
                }

                if isChatLogVisible {
                    ChatLogView(
                        isChatLogVisible: $isChatLogVisible,
                        conversationHistory: conversationHistory
                    )
                    .environmentObject(musicplayer)
                    .zIndex(1)
                }

                if isBackMap {
                    HomeAlert(path: $path,
                              isBackMap: $isBackMap)
                }

                // StoryBranchView.swift の body の最後の方
                if isEndSceneReady {
                    finalStarsView(
                        finalStars: self.finalStars,
                        path: $path
                    )
                    .environmentObject(musicplayer)
                }
            }
            .onAppear {
                gameManager.startStory(storyId: StoryId, allBranchings: allBranchings)

                // --- ✅ デバッグコードここから ---
                print("--- branchingMap の内容チェック ---")
                if branchingMap.isEmpty {
                    print("🚨 エラー: branchingMapが空です。シーンデータが正しくマップに変換されていません。")
                } else {
                    print("✅ OK: branchingMap に \(branchingMap.count)件のシーンが格納されました。")
                    print("マップに含まれる全シーンID:")
                    // sceneIdを昇順にソートして見やすく表示
                    let sortedSceneIds = branchingMap.keys.sorted()
                    print(sortedSceneIds)
                }
                print("--------------------------------\n")

                if let first = currentStoryBranchings.first {
                    currentSceneId = first.sceneId
                    startTyping(fullText: first.text)

                    conversationHistory.append(first)
                }
            }
        }
        .background {
            let sceneToDisplay = currentChoiceScene ?? branchingMap[currentSceneId]
            if let current = sceneToDisplay {
                Image(current.background)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }

    //    三角形アニメーションがループする用の関数
    private func startLoopingAnimation() {
        offsetY = 0.0
        let animation = Animation
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)

        withAnimation(animation) {
            offsetY = 8.0
        }
    }

    func startTyping(fullText: String) {
        displayedText = ""
        currentCharIndex = 0
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            if currentCharIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentCharIndex)
                displayedText.append(fullText[index])
                currentCharIndex += 1
            } else {
                t.invalidate()
                self.isTypingComplete = true
                timer = nil
            }
        }
    }
}

@ViewBuilder
private func characterImage(imageName: String, speakingCharacter: String) -> some View {
    let isSpeaking = (speakingCharacter == imageName)
    let speakingScale: CGFloat = isSpeaking ? 1.1 : 1.0

    Image(imageName)
        .resizable()
        .scaledToFit()
        .scaleEffect(speakingScale)
        .saturation(isSpeaking ? 1.0 : 0.7)
        .brightness(isSpeaking ? 0.0 : -0.2)
        .animation(.easeInOut(duration: 0.3), value: isSpeaking)
}

private func getCharacterNameFromImage(_ imageName: String) -> String {
    let baseName = imageName.components(separatedBy: "_").first ?? imageName
    return CharacterName(rawValue: baseName)?.displayName ?? baseName
}
