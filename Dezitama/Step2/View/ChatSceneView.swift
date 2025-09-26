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
    var scene: Branching
    var isAnimating: Bool = true
    var showText: Bool = false
    var imageIsVisible: Bool = false
    var textIsVisible: Bool = false
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


    @State private var isLarge = false
    @State private var proxy: ScrollViewProxy?


//    scvファイル
    @Binding var allBranchings: [Branching]
    @Binding var allScene: Branching

//    選択肢のポップアップを表示する
    @Binding var isPopupVisible: Bool
//    会話の見返しボタン用関数
    @Binding var conversationHistory: [Branching]
    @Binding var isEndSceneReady: Bool

    let animationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

    var color: Color = .gray
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
//                                                 チャットの画面のスクロール部分
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

//                        Button {
//                            skipAllChatScenes()
//                        } label: {
//                            Text("飛ばす")
//                                .font(.system(size: 20, weight: .bold, design: .default))
//                                .padding(10)
//                                .background(Color.red)
//                                .foregroundColor(.white)
//                                .clipShape(Capsule())
//                        }

                    Button {
                        skipToNextChoice()
                    } label: {
                        Text("選択肢までスキップ")
                            .font(.system(size: 18, weight: .bold))
                            .padding(12)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                    .position(x: geometry.size.width - 120, y: geometry.size.height - 50)

//                    選択肢の問題を出す
                    if isPopupVisible, let choiceScene = currentChoiceScene {
                        isChoiceView(
                            isPopupVisible: $isPopupVisible,
                            allScene: .constant(choiceScene),
                            onChoiceSelected: { selectedText, nextId in
                                // ユーザーが選択したテキストで最後のメッセージを置き換える
                                if let lastMessageIndex = chatMessage.indices.last {
                                    // 既存のシーンデータを取得
                                    let existingScene = chatMessage[lastMessageIndex].scene

                                    // 新しいデータで新しい `Branching` インスタンスを作成
                                    let newScene = Branching(
                                        storyId: existingScene.storyId,
                                        sceneId: existingScene.sceneId,
                                        sceneType: existingScene.sceneType,
                                        groupName: existingScene.groupName,
                                        icon: existingScene.icon,
                                        characterName: existingScene.characterName,
                                        leftCharacter: existingScene.leftCharacter,
                                        centerCharacter: existingScene.centerCharacter,
                                        rightCharacter: existingScene.rightCharacter,
                                        text: selectedText, // 選択肢のテキストで上書き
                                        nextSceneId: nextId, // 選択肢の次のシーンIDで上書き
                                        isChoice: false, // 選択肢ではないので false
                                        choice1Text: existingScene.choice1Text,
                                        choice1Percentage: existingScene.choice1Percentage,
                                        choice1NextSceneId: existingScene.choice1NextSceneId,
                                        choice2Text: existingScene.choice2Text,
                                        choice2Percentage: existingScene.choice2Percentage,
                                        choice2NextSceneId: existingScene.choice2NextSceneId,
                                        choice3Text: existingScene.choice3Text,
                                        choice3Percentage: existingScene.choice3Percentage,
                                        choice3NextSceneId: existingScene.choice3NextSceneId,
                                        bgm: existingScene.bgm,
                                        background: existingScene.background
                                    )

                                    // 新しい `Branching` インスタンスでメッセージを更新
                                    chatMessage[lastMessageIndex].isAnimating = false
                                    chatMessage[lastMessageIndex].showText = true
                                    chatMessage[lastMessageIndex].scene = newScene
                                    conversationHistory[lastMessageIndex] = newScene
                                    allScene = newScene
                                }

                                // ポップアップを閉じる
                                isPopupVisible = false

                                // 次のシーンへ遷移
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    proceedToNextIfNeeded()
                                }
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

                    // 現在タイピングアニメーションが表示されている場合、タップでテキストに切り替える
                    if let lastMessageIndex = chatMessage.indices.last, chatMessage[lastMessageIndex].isAnimating {
                        if chatMessage[lastMessageIndex].scene.isChoice ?? false {
                            isPopupVisible = true
                            currentChoiceScene = chatMessage[lastMessageIndex].scene
                        } else {
                            chatMessage[lastMessageIndex].isAnimating = false
                            chatMessage[lastMessageIndex].showText = true
                            DispatchQueue.main.async {
                                if let last = chatMessage.last {
                                    withAnimation {
                                        self.proxy?.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                            }
                             // テキスト表示後、次の自動進行をチェック
                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                proceedToNextIfNeeded()
                             }
                        }
                        return
                    }

                    guard let last = chatMessage.last else { return }

                    // 最後のメッセージが相手のセリフであり、かつアニメーションが完了していない場合はタップを無効にする
                    if last.scene.characterName != last.scene.rightCharacter && last.isAnimating {
                        return
                    }

                    // ▼▼▼ ここからが修正箇所です ▼▼▼

                    let nextId = last.scene.nextSceneId

                    // nextSceneIdが "end" の場合、isEndSceneReadyをtrueにして終了画面を表示
                    if nextId == "end" {
                        // 1. 親Viewに終了を通知して、スコア保存の処理を呼び出す
                        onNextScene("end")

                        // 2. このViewでも終了画面を表示する準備をする
                        isEndSceneReady = true

                        // 3. 他の処理は行わずに終了する
                        return
                    }

                    // 次のシーンが見つからなければ、親Viewに通知
                    guard let next = branchingMap[nextId] else {
                        onNextScene(nextId)
                        return
                    }

                    // ▲▲▲ ここまでが修正箇所です ▲▲▲

                    if next.sceneType == "chat" {
                        // 次のセリフが主人公の場合、まずアニメーション付きのメッセージを追加
                        if next.characterName == next.rightCharacter {
                            if next.isChoice == true {
                                // 選択肢の場合はタップでポップアップが表示されるように、アニメーション付きメッセージを追加
                                let newMsg = ChatMessage(scene: next, isAnimating: true, showText: false)
                                chatMessage.append(newMsg)
                                conversationHistory.append(newMsg.scene)
                                allScene = newMsg.scene
                                DispatchQueue.main.async {
                                    if let last = chatMessage.last {
                                        withAnimation {
                                            self.proxy?.scrollTo(last.id, anchor: .bottom)
                                        }
                                    }
                                }

                            } else {
                                // 選択肢なしの主人公のセリフはアニメーション付きで追加
                                let newMsg = ChatMessage(scene: next, isAnimating: true, showText: false)
                                chatMessage.append(newMsg)
                                conversationHistory.append(newMsg.scene)
                                allScene = newMsg.scene
                                DispatchQueue.main.async {
                                    if let last = chatMessage.last {
                                        withAnimation {
                                            self.proxy?.scrollTo(last.id, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        } else {
                            // 相手のセリフの場合
                            proceedToNextIfNeeded()
                        }
                    } else {
                        onNextScene(nextId)
                    }
                }
//                ↑ここまでonTapGestureの処理

                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)  {
                    if let first = branchingMap[initialSceneId] {
                        chatMessage = [ChatMessage(scene: first, isAnimating: false, showText: true)]
                        allScene = first
                        DispatchQueue.main.async {
                            if let last = chatMessage.last {
                                withAnimation {
                                    self.proxy?.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }

                        // 最初のセリフが相手のセリフなら、自動で次のセリフを送信
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
            DispatchQueue.main.async {
                if let last = chatMessage.last {
                    withAnimation {
                        self.proxy?.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            // ★ アニメーション終了後、少し間を置いて次の進行をチェックする
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                proceedToNextIfNeeded()
            }
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
        .padding(5)
    }


    @ViewBuilder
    func messageRow(for message: ChatMessage, proxy: ScrollViewProxy) -> some View {
        let scene = message.scene
        HStack {
            if scene.characterName == scene.rightCharacter { Spacer() }

//            主人公じゃない時
            if scene.characterName != scene.rightCharacter {
                VStack {
                    HStack(alignment: .top) {
                        Image(scene.icon)
                            .resizable()
                            .frame(width: 48, height: 48)
                            .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottom)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: message.imageIsVisible)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(CharacterName(rawValue: scene.characterName)?.displayName ?? scene.characterName)
                                .font(.custom("MPLUS1-Regular", size: 18))
                                .foregroundColor(Color.gray)
                                .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottomLeading)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.05), value: message.imageIsVisible)

                            if message.isAnimating {
                                typingAnimationView()
                                     .padding(13)
                                     .font(.system(size: 22))
                                     .background(Color.white.opacity(1.0))
                                     .cornerRadius(16)
                                     .onAppear {
                                         // アニメーション表示時にスクロール
                                         DispatchQueue.main.async {
                                             withAnimation {
                                                 self.proxy?.scrollTo(message.id, anchor: .bottom)
                                             }
                                         }
                                         animationTrigger.toggle()
                                         DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                             animationTrigger.toggle()
                                         }
                                         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                             withAnimation {
                                                 updateMessageState(id: message.id)
                                             }
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
                                .scaleEffect(message.textIsVisible ? 1.0 : 0.8, anchor: .bottomLeading)
                                .opacity(message.textIsVisible ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                                .onAppear {
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            proxy.scrollTo(message.id, anchor: .bottom)
                                        }
                                    }
                                    withAnimation {
                                        if let index = chatMessage.firstIndex(where: { $0.id == message.id }) {
                                            chatMessage[index].imageIsVisible = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                             withAnimation {
                                                 if let index = chatMessage.firstIndex(where: { $0.id == message.id }) {
                                                     chatMessage[index].textIsVisible = true
                                                 }
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
                            .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottomTrailing)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.05), value: message.imageIsVisible)

                        // 主人公のタイピングアニメーション
                        if message.isAnimating {
                            typingAnimationView()
                                .padding(13)
                                .background(Color.white.opacity(1.0))
                                .cornerRadius(16)
                                .scaleEffect(message.textIsVisible ? 1.0 : 0.8, anchor: .bottomTrailing)
                                .opacity(message.textIsVisible ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                                .onAppear {
                                    
                                    // アニメーションを無限ループで表示
                                    animationTrigger.toggle()
                                    DispatchQueue.main.async {
                                        if let last = chatMessage.last {
                                            withAnimation {
                                                self.proxy?.scrollTo(last.id, anchor: .bottom)
                                            }
                                        }
                                    }
                                    // アイコンと名前のアニメーションも開始
                                    withAnimation {
                                        if let index = chatMessage.firstIndex(where: { $0.id == message.id }) {
                                            chatMessage[index].imageIsVisible = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                             withAnimation {
                                                 if let index = chatMessage.firstIndex(where: { $0.id == message.id }) {
                                                     chatMessage[index].textIsVisible = true
                                                 }
                                             }
                                         }
                                }
                                .onReceive(animationTimer) { _ in
                                    animationTrigger.toggle()
                                }
                        }

//                        ルビ付きでテキストを表示
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
                            .frame(maxWidth: 450, alignment: .bottomTrailing)
                            .scaleEffect(message.textIsVisible ? 1.0 : 0.8, anchor: .bottomTrailing)
                            .opacity(message.textIsVisible ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                            .onAppear {
                                DispatchQueue.main.async {
                                    withAnimation {
                                        proxy.scrollTo(message.id, anchor: .bottom)
                                    }
                                }
                                withAnimation {
                                    if let index = chatMessage.firstIndex(where: { $0.id == message.id }) {
                                        chatMessage[index].imageIsVisible = true
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                     withAnimation {
                                         if let index = chatMessage.firstIndex(where: { $0.id == message.id }) {
                                             chatMessage[index].textIsVisible = true
                                         }
                                     }
                                 }
                            }
                        }
                    }
                    Image(scene.icon)
                        .resizable()
                        .frame(width: 48, height: 48)
                        .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottom)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: message.imageIsVisible)
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

        // 選択肢の直前では自動で進まないようにする
        if next.isChoice ?? false {
            // 3秒の遅延後にアニメーション付きのメッセージを追加
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let newMsg = ChatMessage(scene: next, isAnimating: true, showText: false)
                chatMessage.append(newMsg)
                conversationHistory.append(newMsg.scene)
                allScene = next
                isTyping = false
            }
            isTyping = true
            return
        }

        // 次が主人公のセリフの場合、アニメーション付きのメッセージを自動で追加して停止
        if next.characterName == next.rightCharacter {
             // 3秒の遅延後にアニメーション付きのメッセージを追加
             DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                 let newMsg = ChatMessage(scene: next, isAnimating: true, showText: false)
                 chatMessage.append(newMsg)
                 conversationHistory.append(newMsg.scene)
                 allScene = next
                 isTyping = false
             }
             isTyping = true
            return
        }

        // 相手のセリフは自動で進める
        isTyping = true
        pendingMessage = next
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let msg = pendingMessage {
                // 新しいメッセージをisAnimating: false, showText: trueとして追加
                let newMsg = ChatMessage(scene: msg, isAnimating: false, showText: true)
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


    // ChatSceneView の中にこの関数を追加してください
    private func skipToNextChoice() {
        guard let last = chatMessage.last else { return }

        var nextId = last.scene.nextSceneId
        var targetScene: Branching?

        // 次の選択肢か、チャットの終わりを探すループ
        while let next = branchingMap[nextId], next.sceneType == "chat" {
            // もし次のシーンが選択肢なら、そこを目的地に設定してループを抜ける
            if next.isChoice == true {
                targetScene = next
                break
            }
            // 次のシーンへ
            nextId = next.nextSceneId
        }

        // ループの結果で処理を分岐
        if let scene = targetScene {
            // 目的地（選択肢）が見つかった場合
            // 新しいメッセージとしてそれを追加し、アニメーションを表示
            let newMsg = ChatMessage(scene: scene, isAnimating: true, showText: false)
            chatMessage.append(newMsg)
            conversationHistory.append(newMsg.scene) // 会話履歴にも追加
            allScene = newMsg.scene

            // 新しいメッセージが見えるように一番下までスクロール
            DispatchQueue.main.async {
                if let lastMessage = chatMessage.last {
                    withAnimation {
                        proxy?.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        // メモ: 選択肢が見つからなかった場合（会話が終わる場合）は何もしません
    }
}
