//
//  testScrollView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/06/13.
//
import SwiftUI

// 一つのメッセージの情報を保持する構造体
struct ChatMessage: Identifiable {
    let id = UUID()
    let scene: Branching
    var isAnimating: Bool = true
    var showText: Bool = false
}

struct ChatSceneView: View {
    let branchingMap: [String: Branching]
    let initialSceneId: String
    var onNextScene: (String) -> Void


    @State var isTyping = false
    @State var pendingMessage: Branching? = nil

//     アニメーションの表示
    @State var animationTrigger = true
    @State var chatMessage: [ChatMessage] = []
    @State private var triangleAnimationTrigger = false
    @State private var offsetY: CGFloat = 0.0
    @State var currentChoiceScene: Branching? = nil

//    選択肢なしの主人公のセリフ用関数
    @State private var noChoiceMessage: Bool = false


    @State private var isLarge: Bool = false
    @State private var proxy: ScrollViewProxy?


//    scvファイル
    @Binding var allBranchings: [Branching]
    @Binding var allScene: Branching

//    選択肢のポップアップを表示する
    @Binding var isPopupVisible: Bool
//    会話の見返しボタン用関数
    @Binding var conversationHistory: [Branching]

    var color: Color = .blue
    var dotSize: CGFloat = 30
    var bounceHeight: CGFloat = 90
    var repeatCount: Int = 2
    
    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Text(ChatMessage(scene: self.allScene).scene.groupName)
                        .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.123)
                        .font(.custom("MPLUS1-Medium", size: 24))
                    VStack {
//                                        チャットの画面のスクロール部分
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(chatMessage) { message in
                                        messageRow(for: message, proxy: proxy)
                                            .id(message.id)
                                    }
                                }
                                .padding()
                            }
                            .padding(.bottom, 10)
                            .frame(width: 500, height: 450)
                            .position(x: geometry.size.width  * 0.492,y: geometry.size.height * 0.45)
                            .onAppear {
                                self.proxy = proxy
                            }
                        }
                    }

                        HStack {
                            Image("soushin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .padding(40)
                                .scaleEffect(isLarge ? 0.93 : 1)
                                .onAppear {
                                    startLoopingAnimation()
                                }
                                .position(x: geometry.size.width * 0.645, y: geometry.size.height * 0.805)
                        }

                        Button {
                            skipAllChatScenes()
                        } label: {
                            Text("飛ばす")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .padding(10)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .border(Color.yellow, width: 3)

//                     選択肢の問題を出す
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
                                chatMessage.append(ChatMessage(scene: userChoiceScene))
                                conversationHistory.append(userChoiceScene)

                                // 次のシーンへ遷移
                                onNextScene(nextId)
                            }
                        )
                    }
                }
//                ↓ここから送信ボタンをタップした時の処理・Zstackの範囲を全画面に広げてから.onTapGestureの処理を実行
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    if isTyping || isPopupVisible {
                        return
                    }

                    guard let last = chatMessage.last else { return }
                    // 最後のメッセージが相手のセリフであり、かつアニメーションが完了していない場合はタップを無効にする
                    if last.scene.characterName != last.scene.rightCharacter && last.isAnimating {
                        return
                    }
                    let nextId = last.scene.nextSceneId

                    guard let next = branchingMap[nextId] else {
                        onNextScene(nextId)
                        return
                    }

//                                     主人公のセリフだけボタンで進める
                    if next.sceneType == "chat" {
//                        rightchracterで主人公かどうか判断している
                        if next.characterName == next.rightCharacter {
//                            自分のセリフ（即時表示）
                            let newMsg = ChatMessage(scene: next, isAnimating: false, showText: true)
                            allScene = next //  最新のシーンを更新

                            if next.isChoice == true {
                                isPopupVisible = true
                                currentChoiceScene = next
                            } else {
                                chatMessage.append(newMsg)
                                conversationHistory.append(newMsg.scene)
                                DispatchQueue.main.async {
                                    if let last = chatMessage.last {
                                        withAnimation {
                                            self.proxy?.scrollTo(last.id, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        onNextScene(nextId)
                    }

                    // ボタン押した後に「次が相手のセリフ」なら自動で返信
                        proceedToNextIfNeeded()
                }
//                ↑ここまでonTapGestureの処理

                .onAppear {
                    if let first = branchingMap[initialSceneId] {
                        chatMessage = [ChatMessage(scene: first)]
                        allScene = first

                        // 最初のセリフがネトモなら自動で続ける
                        if first.characterName != first.rightCharacter {
                                proceedToNextIfNeeded()
                        }
                    }
                }
            }
    }

    // アニメーション終了時に状態更新する
    private func updateMessageState(id: UUID) {
        if let index = chatMessage.firstIndex(where: { $0.id == id }) {
            chatMessage[index].isAnimating = false
            chatMessage[index].showText = true
        }
    }

    // タイピングアニメーションのView
    @ViewBuilder
    private func typingAnimationView() -> some View {
        HStack(spacing: dotSize * 0.15) {
            ForEach(1..<4) { index in
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .keyframeAnimator(initialValue: 0.0, trigger: animationTrigger) { content, value in
                        content.offset(y: value)
                    } keyframes: { _ in
                        KeyframeTrack {
                            LinearKeyframe(0.0, duration: Double(index) * 0.1)
                            SpringKeyframe(-0.15 * bounceHeight, duration: 0.5)
                            SpringKeyframe(0.0, duration: 0.7)
                        }
                    }
            }
        }
    }


    @ViewBuilder
    func messageRow(for message: ChatMessage, proxy: ScrollViewProxy) -> some View {
        let scene = message.scene
        HStack {
            if scene.characterName == scene.rightCharacter { Spacer() }

            if scene.characterName != scene.rightCharacter {
                VStack {
                    HStack(alignment: .top) {
                        Image(scene.icon)
                            .resizable()
                            .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(CharacterName(rawValue: scene.characterName)?.displayName ?? scene.characterName)
                                .font(.custom("MPLUS1-Regular", size: 18))
                                .foregroundColor(Color.gray)

                            if message.isAnimating {
                                typingAnimationView()
                                    .padding(22)
                                    .font(.system(size: 22))
                                    .background(Color.white.opacity(1.0))
                                    .cornerRadius(16)
                                    .onAppear {
                                        DispatchQueue.main.async {
                                            withAnimation {
                                                self.proxy?.scrollTo(message.id, anchor: .bottom)
                                            }
                                        }

                                        // 最初のアニメーション
                                        animationTrigger.toggle()
                                        // アニメーション時間後に切り替え
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                            animationTrigger.toggle()
                                        }
//                                        2回目のアニメーション
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                                            withAnimation {
                                                updateMessageState(id: message.id)
                                            }
//                                            proceedToNextIfNeeded()
                                        }
                                    }
                            }

//                            ルビつきでテキストを表示
                            if message.showText {
                                RubyLabelRepresentable(
                                    attributedText: scene.text
                                        .replacingOccurrences(of: "<br>", with: "\n")
                                        .createRuby(font: .customFont(ofSize: 22), color: .black),
                                    font: .customFont(ofSize: 22),
                                    textColor: .black,
                                    textAlignment: .left
                                )
                                .padding(13)
                                .background(Color.white.opacity(1.0))
                                .cornerRadius(16)
                                .frame(maxWidth: 350, alignment: .leading)
                                .onAppear {
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            proxy.scrollTo(message.id, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                HStack(alignment: .top){
                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(CharacterName(rawValue: scene.characterName)?.displayName ?? scene.characterName)
                            .font(.custom("MPLUS1-Regular", size: 18))
                            .foregroundColor(Color.gray)

//                        ルビ付きでテキストを表示
                        RubyLabelRepresentable(
                            attributedText: scene.text
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createRuby(font: .customFont(ofSize: 22), color: .black),
                            font: .customFont(ofSize: 22),
                            textColor: .black,
                            textAlignment: .left
                        )
                        .font(.system(size: 22))
                        .padding(13)
                        .background(Color.white.opacity(1.0))
                        .cornerRadius(16)
                        .frame(maxWidth: 450, alignment: .trailing)
                    }
                    Image(scene.icon)
                        .resizable()
                        .frame(width: 48, height: 48)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            if scene.characterName != scene.rightCharacter { Spacer() }
        }
        .padding(.horizontal)
        .id(message.id) // スクロールIDとして使用
    }

//    デバック用のスキップボタン
    private func skipAllChatScenes() {
        guard let last = chatMessage.last else { return }
        var nextId = last.scene.nextSceneId
        while let next = branchingMap[nextId], next.sceneType == "chat" {
            nextId = next.nextSceneId
        }
        onNextScene(nextId)
    }


//    送信ボタンのアニメーション
    private func startLoopingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.7)) {
                isLarge.toggle()
            }
        }
    }

//    次のチャットがネトモだった場合は自動で返信させる関数
    private func proceedToNextIfNeeded() {
//        デバック用コード
        print("proceedToNextIfNeededが呼び出されました。")
        guard let last = chatMessage.last else {
            print("最後のチャットメッセージがありません。")
            return
        }

        let nextId = last.scene.nextSceneId
        print("次のシーンID: \(nextId)")
//        ここ

        if isTyping || isPopupVisible {
            return
        }

        guard let next = branchingMap[nextId] else { return }

        if next.sceneType != "chat" {
            onNextScene(nextId)
            return
        }

        // 選択肢の直前なら止まる
        if next.isChoice ?? false {
            // 選択肢のシーンの場合は、自動遷移を停止し、親ビューに通知する
            isPopupVisible = true
            currentChoiceScene = next // 選択肢のシーンデータを保持
            return
        }

        // 主人公のセリフでは止まる（ユーザー操作待ち）
        if next.characterName == next.rightCharacter {
            return
        }

        // 直前のメッセージが主人公のセリフか、相手のセリフかを判定
        let isLastMessageFromProtagonist = last.scene.characterName == last.scene.rightCharacter

        // 遅延時間を設定
        let delay: TimeInterval = isLastMessageFromProtagonist ? 0.7 : 4.0

        // 相手のセリフは自動で進める
        isTyping = true
        pendingMessage = next
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let msg = pendingMessage {
                let newMsg = ChatMessage(scene: msg)
                chatMessage.append(newMsg)
                conversationHistory.append(newMsg.scene)
                allScene = msg
            }
            pendingMessage = nil
            isTyping = false

            // 続きがあるか再帰
                proceedToNextIfNeeded()
        }
    }
}
