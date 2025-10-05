//
//  NetomoBranchingView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/06/06.
//

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
                                if let next = branchingMap[current.nextSceneId]{
                                    currentSceneId = next.sceneId
                                }
                            }


                        case "chat":
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
                                            .frame(width: 350, height: 500) // 💡 サイズは固定せず、maxWidthで調整する方が良いが、元の指定に合わせる
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
                                // MARK: - キャラクター表示部分
                                // 表示するキャラクターの数を数える
//                                let characterCount = [current.leftCharacter, current.centerCharacter, current.rightCharacter].filter { !$0.isEmpty }.count
//
//                                // HStacをキャラクター数に応じて調整
//                                HStack(spacing: 20) {
//                                    // キャラクターが2人以下の場合は左にSpacerを配置
//                                    if characterCount <= 2 {
//                                        Spacer()
//                                    }
//
//                                    // 左のキャラクター
//                                    if !current.leftCharacter.isEmpty {
//                                        characterImage(
//                                            imageName: current.leftCharacter,
//                                            speakingCharacter: current.characterName
//                                        )
//                                        .frame(width: 250, height: 450)
//                                    }
//
//                                    // キャラクターが1人または2人の場合にSpacerを挿入
//                                    if characterCount == 2 {
//                                        Spacer()
//                                    }
//
//                                    // 中央のキャラクター
//                                    if !current.centerCharacter.isEmpty {
//                                        characterImage(
//                                            imageName: current.centerCharacter,
//                                            speakingCharacter: current.characterName
//                                        )
//                                        .frame(width: 250, height: 450)
//                                    }
//
//                                    // キャラクターが1人または2人の場合にSpacerを挿入
//                                    if characterCount == 1 || characterCount == 2 {
//                                        Spacer()
//                                    }
//
//                                    // 右のキャラクター
//                                    if !current.rightCharacter.isEmpty {
//                                        characterImage(
//                                            imageName: current.rightCharacter,
//                                            speakingCharacter: current.characterName
//                                        )
//                                        .frame(width: 250, height: 450)
//                                    }
//
//                                    // キャラクターが2人以下の場合は右にSpacerを配置
//                                    if characterCount <= 2 {
//                                        Spacer()
//                                    }
//                                }
//                                .position(x: geometry.size.width/2,y: geometry.size.height * 0.5)
//                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)


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
                                        font: talkFont
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
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // ポップアップ表示中はタップを無効にする
                                if isPopupVisible {
                                    print("ポップアップ表示中のためタップを無効にします。")
                                    return
                                }

                                if let replyScene = currentChoiceScene {
                                    let nextActualId = replyScene.nextSceneId
                                    self.currentChoiceScene = nil // 一時シーンをクリア
                                    self.currentSceneId = nextActualId
                                    return
                                }

                                if !isTypingComplete {
                                    shouldSkipTyping = true
                                    isTypingComplete = true
                                } else {
                                    if let current = branchingMap[currentSceneId], let next = branchingMap[current.nextSceneId] {
                                        historyStack.append(currentSceneId)

                                        // 次のシーンが選択肢の場合
                                        if next.isChoice == true {
                                            isPopupVisible = true
                                            currentChoiceScene = next
                                        } else {
                                            currentSceneId = next.sceneId
                                        }
                                        conversationHistory.append(next)

                                    } else if let current = branchingMap[currentSceneId], current.nextSceneId == "end" {
                                        if !isEndSceneReady {
                                            let stars = gameManager.scoreToStars(score: gameManager.currentScore)
                                            self.finalStars = stars
                                            gameManager.completeStage(stageId: self.stageId, mode: self.mode, earnedScore: stars)
                                            isEndSceneReady = true
                                        }
                                    }
                                }
                            }

                        default:
                            Text("このscemneTypeは未対応です")
                        }
                    }
                } else {
                    Text("ストーリーが読み込めませんでしたnetomoBranchView")
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
//                        会話見返し機能
                            Button(action: {
                                musicplayer.playSE(fileName: "button_SE")
                                isChatLogVisible.toggle()
                            }) {
                                Image("chat") // chatボタンを流用
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .padding(20)
                            }
                            .zIndex(0)
                            Spacer()

                    }
                    Spacer()
                    VStack {
                        Gauge(width: geometry.size.width * 0.3, height: 100,
                              score: gameManager.currentScore,
                              currentMode: $currentMode)
                            .padding(.trailing,2)
                        Spacer()

                    }
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
                    Color.black
                        .opacity(0.45)
                        .ignoresSafeArea()

                    VStack {
                        Spacer()

                        // finalStarsの値に応じてテキストを表示
                        switch finalStars {
                        case 1:
                            //                            Image("final_star1")
                            Text("星１")
                                .font(.system(size: 100, weight: .bold))
                                .foregroundColor(.yellow)
                        case 2:
                            //                            Image("final_star2")
                            Text("星２")
                                .font(.system(size: 100, weight: .bold))
                                .foregroundColor(.yellow)
                        case 3:
                            //                            Image("final_star3")
                            Text("星３")
                                .font(.system(size: 100, weight: .bold))
                                .foregroundColor(.yellow)
                        default:
                            Text("もう少し！") // 星0個の場合
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        HStack {
                            Spacer()
                            Button {
                                musicplayer.playSE(fileName: "button_SE")
                                path.removeLast()
                            } label: {
                                Image("back_start")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 500, height: 100)
                            }
                        }
                    }
                }
            }
            .onAppear {
                // ビューが表示されたら、GameManagerのストーリー開始処理を呼ぶ
                gameManager.startStory(storyId: StoryId, allBranchings: allBranchings)

                if let first = currentStoryBranchings.first { // ★ filterされたストーリーの先頭を取得する
                    currentSceneId = first.sceneId
                    startTyping(fullText: first.text)
                    //                    見返し機能用
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
            }
        }
    }

    //    三角形アニメーションがループする用の関数
    private func startLoopingAnimation() {
        // 一旦アニメーションをリセット
        offsetY = 0.0
        // 新たにアニメーション
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
    let speakingScale: CGFloat = isSpeaking ? 1.1 : 1.0 // 話し手は1.1倍に拡大

    Image(imageName)
        .resizable()
        .scaledToFit()
        .scaleEffect(speakingScale)
        .saturation(isSpeaking ? 1.0 : 0.7) // 彩度を30%に下げる
        .brightness(isSpeaking ? 0.0 : -0.2) // 明るさを20%下げる
        .animation(.easeInOut(duration: 0.3), value: isSpeaking)
}

private func getCharacterNameFromImage(_ imageName: String) -> String {
    let baseName = imageName.components(separatedBy: "_").first ?? imageName
    return CharacterName(rawValue: baseName)?.displayName ?? baseName
}
