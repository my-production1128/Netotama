//
//  NetomoBranchingView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/06/06.
//

import Lottie
import SwiftUI

struct StoryBranchView: View {
    @State private var currentSceneId: String
    @State private var historyStack: [String] = []
    @State private var showSpecialView: Bool = false
    @State private var offsetY: CGFloat = 0.0
    @State var isPopupVisible: Bool = false
    @State var nextChat: Bool = false
    @State private var displayedText = ""
    @State private var currentCharIndex = 0
    @State private var timer: Timer? = nil
    @State private var isTypingComplete: Bool = true
    @State private var shouldSkipTyping: Bool = false
    @State private var currentChoiceScene: Branching? = nil
    @State var isChatLogVisible: Bool = false
    @State private var conversationHistory: [Branching]
    @State var isEndSceneReady: Bool = false
    @State private var finalStars: Int = 0
    @State var isBackMap: Bool = false
    @State private var showResultButton: Bool = false
    @State private var storylineOpacity: Double = 0.0
    @State private var isStorylineInteractable: Bool = false
    @State private var screenTextOffset: CGFloat = 0.0

    @EnvironmentObject private var gameManager: GameManager
    @EnvironmentObject var musicplayer: SoundPlayer

    @Binding var path: NavigationPath
    @Binding var allBranchings: [Branching]
    @Binding var allScene: Branching

    let stageId: Int
    let talkFont = UIFont.customFont(ofSize: 30)
    let charaNameFont = UIFont.customFont(ofSize: 35)
    let StoryId: String

    private var currentStoryBranchings: [Branching] {
        return allBranchings.filter { $0.storyId == StoryId }
    }

    private var branchingMap: [String: Branching] {
        var map: [String: Branching] = [:]
        for b in currentStoryBranchings {
            if map[b.sceneId] == nil {
                map[b.sceneId] = b
            } else {
                print("Duplicate sceneId found in the same story: \(b.sceneId)")
            }
        }
        return map
    }

    init(path: Binding<NavigationPath>,
         allBranchings: Binding<[Branching]>,
         allScene: Binding<Branching>,
         StoryId: String,
         stageId: Int) {

        self._path = path
        self._allBranchings = allBranchings
        self._allScene = allScene
        self.StoryId = StoryId
        self.stageId = stageId

        let firstScene: Branching? = allBranchings.wrappedValue
            .filter { $0.storyId == StoryId }
            .first

        let firstSceneId = firstScene?.sceneId ?? "scene1"
        self._currentSceneId = State(initialValue: firstSceneId)

        if let first = firstScene, (first.sceneType == "talk" || first.sceneType == "chat") {
            self._conversationHistory = State(initialValue: [first])
        } else {
            self._conversationHistory = State(initialValue: [])
        }
    }


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let sceneToDisplay = currentChoiceScene ?? branchingMap[currentSceneId]
                if let current = sceneToDisplay {
                    VStack {
                        Spacer()
                        switch current.sceneType {

                            //                            あらすじ
                        case "storyline":
                            StorylineView(
                                current: current,
                                geometry: geometry,
                                talkFont: talkFont,
                                branchingMap: branchingMap,
                                offsetY: offsetY,
                                startLoopingAnimation: startLoopingAnimation,
                                currentSceneId: $currentSceneId,
                                currentChoiceScene: $currentChoiceScene,
                                isPopupVisible: $isPopupVisible,
                                conversationHistory: $conversationHistory,
                                storylineOpacity: $storylineOpacity,
                                isStorylineInteractable: $isStorylineInteractable
                            )
                            .environmentObject(musicplayer)

                        case "screen":
                            ScreenSceneView(
                                current: current,
                                geometry: geometry,
                                talkFont: talkFont,
                                branchingMap: branchingMap,
                                currentSceneId: $currentSceneId,
                                currentChoiceScene: $currentChoiceScene,
                                isPopupVisible: $isPopupVisible,
                                conversationHistory: $conversationHistory,
                                screenTextOffset: $screenTextOffset
                            )
                            .environmentObject(musicplayer)

                        case "chat", "chat_picture":
                            ChatSceneView(
                                branchingMap: branchingMap,
                                initialSceneId: currentSceneId,
                                onNextScene: { nextId in
                                    switch nextId.lowercased() {
                                    case "end":
                                        print("StoryBranchView received 'end' from ChatSceneView. Showing result button.")
                                        if !showResultButton {
                                            showResultButton = true
                                        }
                                    case "showresultbutton":
                                        print("StoryBranchView received 'showResultButton'. Showing result button.")
                                        if !showResultButton {
                                            showResultButton = true
                                        }
                                    default:
                                        print("StoryBranchView received next scene ID: \(nextId)")
                                        guard branchingMap[nextId] != nil else {
                                            print("Error: ChatSceneView requested invalid next scene ID: \(nextId)")
                                            return
                                        }
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
                            .id(current.id)
                            .onAppear {
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
                                            return
                                        }
                                        if nextScene.isChoice == true {
                                            isPopupVisible = true
                                            currentChoiceScene = nextScene
                                        } else {
                                            if nextScene.sceneType == "talk" || nextScene.sceneType == "chat" {
                                                conversationHistory.append(nextScene)
                                            }
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
                                    musicplayer.playBGM(fileName: current.bgm)
                                }
                            }

                        case "talk":
                            TalkSceneView(
                                current: current,
                                geometry: geometry,
                                talkFont: talkFont,
                                branchingMap: branchingMap,
                                offsetY: offsetY,
                                startLoopingAnimation: startLoopingAnimation,
                                currentSceneId: $currentSceneId,
                                currentChoiceScene: $currentChoiceScene,
                                isPopupVisible: $isPopupVisible,
                                conversationHistory: $conversationHistory,
                                historyStack: $historyStack
                            )
                            .environmentObject(musicplayer)
                            .id(current.id)


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

                            let userChoiceScene = Branching(
                                storyId: choiceScene.storyId,
                                sceneId: choiceScene.sceneId,
                                sceneType: "talk",
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

                            conversationHistory.append(userChoiceScene)

                            self.currentChoiceScene = userChoiceScene
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isPopupVisible = false
                            }
                        }
                    )
                }

                HStack {
                    VStack {
                        Button {
                            musicplayer.playSE(fileName: "button_SE")
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
                        HStack {
                            Spacer()
                            Gauge(
                                width: geometry.size.width * 0.3,
                                height: 100,
                                score: gameManager.currentScore
                            )
                            .padding()
                            .environmentObject(gameManager)
                        }
                        HStack {
                            Spacer()
                            Button(action: {
                                musicplayer.playSE(fileName: "button_SE")
                                isChatLogVisible.toggle()
                            }) {
                                Image("chat")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .padding(.trailing, 30)
                            }
                            .zIndex(0)
                        }
                        Spacer()
                    }
                }

                if showResultButton {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Button {
                                musicplayer.playSE(fileName: "button_SE")
                                print("成績ボタンが押されました。結果を表示します。")
                                if !isEndSceneReady {
                                    let stars = gameManager.scoreToStars(score: gameManager.currentScore)
                                    self.finalStars = stars
                                    gameManager.completeStage(stageId: self.stageId, mode: gameManager.currentMode, earnedScore: stars)
                                    isEndSceneReady = true
                                }
                            } label: {
                                Image("good_seiseki")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 250, height: 250)
                            }
                            .offset(x: 0, y: 40)
                        }
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

                if isEndSceneReady {
                    finalStarsView(
                        finalStars: self.finalStars,
                        path: $path
                    )
                    .environmentObject(musicplayer)
                }
            }
            .onChange(of: currentSceneId) { _, newSceneId in
                checkIfLastScene(sceneId: newSceneId)
            }
            .onChange(of: isTypingComplete) { _, newValue in
                if newValue {
                    checkIfLastScene(sceneId: currentSceneId)
                }
            }
            .onAppear {
                gameManager.startStory(storyId: StoryId, allBranchings: allBranchings)
                // デバッグコード
                if branchingMap.isEmpty {
                    print("エラー: branchingMapが空です。シーンデータが正しくマップに変換されていません。")
                } else {
                    print("OK: branchingMap に \(branchingMap.count)件のシーンが格納されました。")
                    print("マップに含まれる全シーンID:")
                    let sortedSceneIds = branchingMap.keys.sorted()
                    print(sortedSceneIds)
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

    private func checkIfLastScene(sceneId: String) {
            guard let scene = branchingMap[sceneId] else { return }

            if scene.nextSceneId.lowercased() == "end" && !isEndSceneReady && !showResultButton {

                if scene.sceneType == "talk" {
                    if isTypingComplete {
                        print("最後の talk シーンのタイピング完了。成績ボタンを表示します。")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                             showResultButton = true
                        }
                    } else {
                        print("最後の talk シーンですが、タイピング中のためボタンはまだ表示しません。")
                    }
                } else {
                    print("最後のシーン (\(scene.sceneType)) です。成績ボタンを表示します。")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                         showResultButton = true
                    }
                }
            } else if scene.nextSceneId.lowercased() != "end" && showResultButton {
                showResultButton = false
            }
        }
}
