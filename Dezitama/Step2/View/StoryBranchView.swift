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
    @State private var isEndSceneReady: Bool = false


    let talkFont = UIFont.customFont(ofSize: 30)
    let charaNameFont = UIFont.customFont(ofSize: 35)

    @Binding var path: NavigationPath
    @Binding var allBranchings: [Branching]
    @Binding var allScene: Branching

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

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let current = branchingMap[currentSceneId] {
                    VStack {
                        Spacer()

                        //                    scenetypeがchatの時
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
                                    //                                    print("StoryBranchView: onNextSceneが呼ばれました。nextId = \(nextId)")
                                    historyStack.append(currentSceneId)
                                    currentSceneId = nextId
                                },
                                allBranchings: $allBranchings,
                                allScene: $allScene,
                                isPopupVisible: $isPopupVisible,
                                conversationHistory: $conversationHistory
                            )

                            //                            scenetypeがtalkの
                        case "talk":
                            ZStack {
                                // MARK: - キャラクター表示部分
                                // 表示するキャラクターの数を数える
                                let characterCount = [current.leftCharacter, current.centerCharacter, current.rightCharacter].filter { !$0.isEmpty }.count

                                // HStacをキャラクター数に応じて調整
                                HStack(spacing: 20) {
                                            // キャラクターが2人以下の場合は左にSpacerを配置
                                            if characterCount <= 2 {
                                                Spacer()
                                            }

                                            // 左のキャラクター
                                            if !current.leftCharacter.isEmpty {
                                                characterImage(
                                                    imageName: current.leftCharacter,
                                                    speakingCharacter: current.characterName
                                                )
                                                .frame(width: 250, height: 450)
                                            }

                                            // キャラクターが1人または2人の場合にSpacerを挿入
                                            if characterCount == 2 {
                                                Spacer()
                                            }

                                            // 中央のキャラクター
                                            if !current.centerCharacter.isEmpty {
                                                characterImage(
                                                    imageName: current.centerCharacter,
                                                    speakingCharacter: current.characterName
                                                )
                                                .frame(width: 250, height: 450)
                                            }

                                            // キャラクターが1人または2人の場合にSpacerを挿入
                                            if characterCount == 1 || characterCount == 2 {
                                                Spacer()
                                            }

                                            // 右のキャラクター
                                            if !current.rightCharacter.isEmpty {
                                                characterImage(
                                                    imageName: current.rightCharacter,
                                                    speakingCharacter: current.characterName
                                                )
                                                .frame(width: 250, height: 450)
                                            }

                                            // キャラクターが2人以下の場合は右にSpacerを配置
                                            if characterCount <= 2 {
                                                Spacer()
                                            }
                                        }
                                .position(x: geometry.size.width/2,y: geometry.size.height * 0.5)
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
                                        font: talkFont // ← 修正
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
                            //                            ↓ここから送信ボタンをタップした時の処理
                            //                            Zstackの範囲を全画面に広げてから.onTapGestureの処理を実行
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // ポップアップ表示中はタップを無効にする
                                if isPopupVisible {
                                    print("ポップアップ表示中のためタップを無効にします。")
                                    return
                                }

                                if let next = branchingMap[current.nextSceneId] {
                                    historyStack.append(currentSceneId)
                                    // 次のシーンが選択肢の場合
                                    if next.isChoice == true {
                                        isPopupVisible = true
                                        currentChoiceScene = next
                                        // ここにprint文を追加
                                        print("次のシーンは選択肢です。isPopupVisible: \(isPopupVisible), choiceSceneId: \(currentChoiceScene?.sceneId ?? "nil")")
                                    } else {
                                        currentSceneId = next.sceneId
                                        print("次のシーンに遷移します。sceneId: \(currentSceneId)")
                                    }
                                    conversationHistory.append(next)
                                }else if current.nextSceneId == "end" {
                                    isEndSceneReady = true
                                }
                            }
                            //                            ↑ここまでonTapGestureの処理

                        default:
                            Text("このscemneTypeは未対応です")
                        }
                    }
                    .background {
                        Image(current.background)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    }
                    .ignoresSafeArea()
                } else {
                    Text("ストーリーが読み込めませんでしたnetomoBranchView")
                }

                HStack {
                    VStack {
//                        ホームボタン
                        Button {
                            path.removeLast()
                        }label: {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(.top, 0)
                        }
//                        会話見返し機能
                            Button(action: {
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
                        Gauge(width: geometry.size.width * 0.3, height: 100)
                            .padding(.trailing,2)
                        Spacer()

                    }
                }

                if isChatLogVisible {
                    GeometryReader { innerGeometry in
                        // ★ 全体をZStackで囲む
                        ZStack(alignment: .leading) {
                            // ★ 1. 背景をタップ可能にして閉じるロジックを追加
                            Color.black.opacity(0.001)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        isChatLogVisible = false
                                    }
                                }
                                .zIndex(0) // 背景を一番後ろに

                            // ★ 2. スクロールビュー
                            ScrollViewReader { proxy in
                                ScrollView {
                                    VStack(spacing: 12) {
                                        ForEach(conversationHistory, id: \.id) { scene in
                                            let isRight = scene.characterName == scene.rightCharacter
                                            let characterName = CharacterName(rawValue: scene.characterName)?.displayName ?? "不明"

                                            HStack(alignment: .bottom, spacing: 8) {
                                                if !isRight {
                                                    Image(scene.icon)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30, height: 30)
                                                        .clipShape(Circle())
                                                }

                                                VStack(alignment: isRight ? .trailing : .leading, spacing: 4) {
                                                    Text(characterName)
                                                        .font(.custom("MPLUS1-Regular", size: 14))
                                                        .foregroundColor(.white)

                                                    RubyLabelRepresentable(
                                                        attributedText: scene.text
                                                            .replacingOccurrences(of: "<br>", with: "\n")
                                                            .createRuby(font: .customFont(ofSize: 22),
                                                                        color: .black),
                                                        font: .systemFont(ofSize: 20),
                                                        textColor: .black,
                                                        textAlignment: .left
                                                    )
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .font(.body)
                                                    .foregroundColor(.black)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .fill(Color.white)
                                                    )
                                                }
                                                .frame(maxWidth: 250, alignment: isRight ? .trailing : .leading)

                                                if isRight {
                                                    Image(scene.icon)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30, height: 30)
                                                        .clipShape(Circle())
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: isRight ? .trailing : .leading)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 4)
                                            .id(scene.id)
                                        }
                                    }
                                    .padding()
                                }
                                .background(Color.black.opacity(0.8)) // スクロールビューの背景
                                .frame(width: innerGeometry.size.width / 2)
                                .onAppear {
                                    if let last = conversationHistory.last {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                            }
                            .zIndex(1) // スクロールビューを背景より手前に配置
                            .transition(.move(edge: .leading))
                        }
                    }
                    .zIndex(1) // 履歴ビュー全体をボタンの背後に配置
                }


                if isPopupVisible, let choiceScene = currentChoiceScene {
                    isChoiceView(
                        isPopupVisible: $isPopupVisible,
                        allScene: .constant(choiceScene),
                        onChoiceSelected: { selectedText, nextId in
                            // ユーザーが選択したテキストをチャット履歴に追加
                            let userChoiceScene = Branching(
                                storyId: choiceScene.storyId,
                                sceneId: "user_\(UUID().uuidString)", // ユニークなIDを生成
                                sceneType: "chat",
                                groupName: choiceScene.groupName, // 適切な値を設定
                                icon: choiceScene.icon, // 主人公のアイコン
                                characterName: choiceScene.rightCharacter, // 主人公の名前
                                leftCharacter: "",
                                centerCharacter: "",
                                rightCharacter: choiceScene.rightCharacter,
                                text: selectedText, // 選択されたテキスト
                                nextSceneId: nextId,
                                isChoice: false, // 選択肢としては扱わない
                                choice1Text: "",
                                choice1Type: "",
                                choice1Percentage: nil,
                                choice1NextSceneId: "",
                                choice2Text: "",
                                choice2Type: "",
                                choice2Percentage: nil,
                                choice2NextSceneId: "",
                                choice3Text: "",
                                choice3Type: "",
                                choice3Percentage: nil,
                                choice3NextSceneId: "",
                                bgm: "",
                                background: ""
                            )

                            // 新しいメッセージとして会話履歴に追加し、画面をスクロール
//                            chatMessage.append(ChatMessage(scene: userChoiceScene))
//                            conversationHistory.append(userChoiceScene)

                            // 次のシーンへ遷移
//                            onNextScene(nextId)
                        }
                    )
                }

                if isEndSceneReady {
                    Color.black
                        .opacity(0.45)
                        .ignoresSafeArea()
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
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
                if let first = currentStoryBranchings.first { // ★ filterされたストーリーの先頭を取得する
                    currentSceneId = first.sceneId
                    startTyping(fullText: first.text)
                    //                    見返し機能用
                    conversationHistory.append(first)
                }
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
    //        .opacity(isSpeaking ? 1.0 : 0.7)
    // ★ 話し手以外は彩度と明るさを調整してグレーアウト
        .saturation(isSpeaking ? 1.0 : 0.7) // 彩度を30%に下げる
        .brightness(isSpeaking ? 0.0 : -0.2) // 明るさを20%下げる
        .animation(.easeInOut(duration: 0.3), value: isSpeaking)
}

private func getCharacterNameFromImage(_ imageName: String) -> String {
    let baseName = imageName.components(separatedBy: "_").first ?? imageName
    return CharacterName(rawValue: baseName)?.displayName ?? baseName
}

enum CharacterPosition {
    case left, center, right
}
