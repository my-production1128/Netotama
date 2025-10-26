//
//  ChatMessageView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/10/01.
//

import SwiftUI

// MARK: - 一つのメッセージ情報
struct ChatMessage2: Identifiable {
    let id = UUID()
    var dialogue: Dialogue2
    var isAnimating: Bool = true
    var showText: Bool = false
    var imageIsVisible: Bool = false
    var textIsVisible: Bool = false
    var isPicture: Bool = false
}

// MARK: - チャットビュー本体
struct ChatMessageView: View {
    let dialogues: [Dialogue2]
    let initialSceneId: String
    var onNextScene: (String) -> Void

    @State private var currentSceneId: String
    @EnvironmentObject private var gameManager: GameManager
    @EnvironmentObject var musicplayer: SoundPlayer

    @Binding var path: NavigationPath
    @Binding var conversationHistory: [Dialogue2]

    @State private var chatMessages: [ChatMessage2] = []
    @State private var proxy: ScrollViewProxy?

    @State private var isLarge = false
    @State private var isTyping = false

    @State private var isChatLogVisible: Bool = false
    @State private var isPopupVisible: Bool = false
    @State private var currentChoiceDialogue: Dialogue2? = nil


    @State private var isHintBlinking: Bool = false


    @State private var animationTrigger = true
    let animationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

    var color: Color = .gray
    var dotSize: CGFloat = 30
    var bounceHeight: CGFloat = 90

    //　dialogues を辞書に変換
    private var dialogueMap: [String: Dialogue2] {
        Dictionary(uniqueKeysWithValues: dialogues.map { ($0.sceneId, $0) })
    }

    //現在の dialogue
    private var dialogue: Dialogue2? {
        dialogues.first(where: { $0.sceneId == currentSceneId })
    }

    init(dialogues: [Dialogue2],
         initialSceneId: String,
         onNextScene: @escaping (String) -> Void,
         path: Binding<NavigationPath>,
         conversationHistory: Binding<[Dialogue2]>) {

        self.dialogues = dialogues
        self.initialSceneId = initialSceneId
        self.onNextScene = onNextScene
        self._currentSceneId = State(initialValue: initialSceneId)
        self._path = path
        self._conversationHistory = conversationHistory
    }

    // MARK: - Body
    var body: some View {
        let _ = print("Hint Check: isAnimating=\(chatMessages.last?.isAnimating ?? false), isPopup=\(isPopupVisible), didShow=\(gameManager.didShowChatTapHint)")
        ZStack {
            // チャット本文
            VStack { //
                // 上の Spacer は元々ないのでOK

                ScrollViewReader { proxy in //
                    ScrollView { //
                        VStack(spacing: 0) { //
                            ForEach(chatMessages) { message in //
                                messageRow(for: message, proxy: proxy) //
                                    .id(message.id) //
                            }
                        }
                    }
                    .frame(width: 420, height: 560)
                    .offset(x: 15, y: 55) // 幅は維持するなら maxWidth
                    .frame(maxHeight: .infinity) // 高さは利用可能な最大まで
                    .background(Color.clear)
                    .onAppear {
                        self.proxy = proxy
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if chatMessages.last?.isAnimating == true && !isPopupVisible && !gameManager.didShowChatTapHint {
                Image("tap")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .opacity(isHintBlinking ? 1.0 : 0.0)
                    .onAppear {
                        // 点滅アニメーションを開始するだけにする
                        isHintBlinking = false
                         DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                                isHintBlinking = true
                            }
                        }
                    }
                    .onDisappear {
                        isHintBlinking = false
                    }
            }

            // Body の ZStack 内
            if isPopupVisible, let choiceDialogue = currentChoiceDialogue {
                BadChoiceView(
                    dialogue: choiceDialogue,
                    isPopupVisible: $isPopupVisible,
                    onChoiceSelected: {
                        selectedText,
                        nextId,
                        percentage in
                        handleChoiceSelected(selectedText:selectedText,
                                             nextId: nextId,
                                             percentage: percentage)
                    }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        // ChatMessageView.swift (body内)

        .onAppear {
//            isTapImageVisible = false
            DispatchQueue.main.async {
                if let startDialogue = dialogue {

                    // 1. 最初のメッセージを「即時表示」で作成
                    let initialMsg = ChatMessage2(dialogue: startDialogue,
                                                  isAnimating: false,
                                                  showText: true,
                                                  imageIsVisible: true, // 即時表示
                                                  textIsVisible: true) // 即時表示

                    chatMessages = [initialMsg]

                    // 2. ★ 不足していた履歴への追加
                    conversationHistory.append(startDialogue)

                    DispatchQueue.main.async {
                        if let last = chatMessages.last {
                            withAnimation {
                                self.proxy?.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }

                    // 3. ★ 1.5秒待ってから次のセリフの処理を開始
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        proceedToNextIfNeeded()
                    }
                }
            }
        }
        .onTapGesture {
            // ポップアップ表示中はタップを無視
            if isPopupVisible { //
                print("タップ無視: ポップアップ表示中")
                return //
            }

            // 最後のメッセージを取得
            guard let lastMessage = chatMessages.last else {
                print("タップ無視: メッセージが存在しない")
                return
            }

            // -------------------- 修正点 --------------------
            // コニーのアニメーション中をタップした場合
            if lastMessage.dialogue.characterName == "コニー", lastMessage.isAnimating {
                if !gameManager.didShowChatTapHint { // まだ保存されていなければ
                    print("### .onTapGesture: didShowChatTapHint を true に変更します！ ###")
                            gameManager.didShowChatTapHint = true
                            gameManager.saveProgress()
                            print("「tap」ヒントを見てタップしました。今後は表示しません。")
                        }

                // (1) もし、そのシーンが「選択肢」だったら
                if lastMessage.dialogue.isChoice == true {
                    print("タップ検知: コニーのアニメーション -> 選択肢ポップアップを表示します。")

                    // テキストは表示せず、選択肢ポップアップを直接表示する
                    currentChoiceDialogue = lastMessage.dialogue
                    isPopupVisible = true
                }
                else {
                    print("タップ検知: コニーのアニメーションをスキップします (通常のテキスト)。")

                    // 従来のロジック：アニメーションを停止し、テキストを表示する
                    if let index = chatMessages.firstIndex(where: { $0.id == lastMessage.id }) {
                        chatMessages[index].isAnimating = false // アニメーション停止
                        chatMessages[index].showText = true     // テキスト表示フラグON
                        chatMessages[index].textIsVisible = true  // 表示状態を即時反映

                        scrollToBottom() //
                        isTyping = false

                        // アニメーションをスキップしたので、次の進行を促す
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proceedToNextIfNeeded() //
                        }
                    }
                }
                return // ★ コニーのタップ処理が完了したのでここで終了 ★
            }    else if !lastMessage.isAnimating {
                print("タップ検知: アニメーション中でないため、'end' チェックを行います。")

                // ★ 最後のメッセージの nextSceneId が "end" かどうかをチェック
                if lastMessage.dialogue.nextSceneId?.lowercased() == "end" {
                    print("タップ検知: 'end' が検出されたため、終了処理を呼び出します。")

                    // ★ 'end' だった場合のみ、親に通知する
                    onNextScene("end")
                } else {
                    print("タップ検知: 'end' ではありません。 (nextId: \(lastMessage.dialogue.nextSceneId ?? "nil"))")
                    // 'end' でなければ、タップしても何もしない
                    // (自動進行は proceedToNextIfNeeded が担当するため)
                }
            }
            // -------------------- 修正ここまで --------------------


            print("タップ検知: コニーのアニメーション中でないため、特別な処理なし")
        }
    }
}

// MARK: - サブビュー
extension ChatMessageView {

    @ViewBuilder
    func messageRow(for message: ChatMessage2, proxy: ScrollViewProxy) -> some View {
        normalMessageView(for: message, proxy: proxy)
    }

    @ViewBuilder
    private func normalMessageView(for message: ChatMessage2, proxy: ScrollViewProxy) -> some View {
        let dialogue = message.dialogue

        // コニーなら右側
        let isRight = (dialogue.characterName == "コニー")

        HStack {
            if isRight { Spacer() }

            // 左側（相手キャラ）
            if !isRight {
                HStack(alignment: .top) {
                    characterIcon(for: dialogue.characterName ?? "", size: 48)
                        .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottom)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: message.imageIsVisible)
                        .onAppear { // ★アイコン表示時にトリガー★
                            DispatchQueue.main.async { // スクロールは即時
                                withAnimation { proxy.scrollTo(message.id, anchor: .bottom) }
                            }
                            if !message.imageIsVisible { // まだ表示されていなければアニメーション開始
                                withAnimation {
                                    if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                        chatMessages[index].imageIsVisible = true
                                        musicplayer.playSE(fileName: "icon_SE")
                                    }
                                }
                            }
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(dialogue.characterName ?? "")
                            .font(.custom("MPLUS1-Regular", size: 18))
                            .foregroundColor(.gray)
                            .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottomLeading)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.05), value: message.imageIsVisible)

                        // --- 画像またはテキスト ---
                        if message.isPicture, let text = dialogue.dialogueText {
                            Image(text)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .cornerRadius(16)
                                .padding(.bottom, 8)
                                .scaleEffect(message.textIsVisible ? 1.0 : 0.8, anchor: .bottomLeading)
                                .opacity(message.textIsVisible ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                                .onAppear { // ★吹き出し部分表示時にトリガー★
                                    if !message.textIsVisible { // まだ表示されていなければ遅延アニメーション開始
                                        // 0.8秒遅れて表示アニメーション開始
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                            withAnimation {
                                                if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                                    chatMessages[index].textIsVisible = true
                                                }
                                            }
                                        }
                                    }
                                }
                        } else if message.showText, let text = dialogue.dialogueText {
                            RubyLabelRepresentable(
                                attributedText: text.replacingOccurrences(of: "<br>", with: "\n")
                                    .createRuby(font: .customFont(ofSize: 22), color: .black),
                                font: .customFont(ofSize: 22),
                                textColor: .black,
                                textAlignment: .left,
                                targetWidth: 270
                            )
                            .padding(13)
                            .background(Color.white)
                            .cornerRadius(16)
                            .frame(maxWidth: 450, alignment: .leading)
                            .padding(.bottom, 8)
                            .scaleEffect(message.textIsVisible ? 1.0 : 0.8, anchor: .bottomLeading)
                            .opacity(message.textIsVisible ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                            .onAppear { // ★吹き出し部分表示時にトリガー★
                                if !message.textIsVisible { // まだ表示されていなければ遅延アニメーション開始
                                    // 0.8秒遅れて表示アニメーション開始
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        withAnimation {
                                            if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                                chatMessages[index].textIsVisible = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 右側（コニー）
            } else if isRight {
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(dialogue.characterName ?? "")
                            .font(.custom("MPLUS1-Regular", size: 18))
                            .foregroundColor(Color.gray)
                            .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottomTrailing)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.05), value: message.imageIsVisible)

                        // --- コニー専用 typingAnimation → 本文 ---
                        if dialogue.characterName == "コニー" {
                            if message.isAnimating {
                                typingAnimationView()
                                    .padding(13)
                                    .background(Color.white.opacity(1.0))
                                    .cornerRadius(16)
                                    .padding(.bottom, 8)
                                    .scaleEffect(message.textIsVisible ? 1.0 : 0.8, anchor: .bottomTrailing)
                                    .opacity(message.textIsVisible ? 1.0 : 0.0)
                                    .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                                    .onAppear { // ★typingAnimationView表示時にトリガー★
                                        animationTrigger.toggle()
                                        if !message.textIsVisible { // まだ表示されていなければ遅延アニメーション開始
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                withAnimation {
                                                    if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                                        chatMessages[index].textIsVisible = true // typingAnimationを表示
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .onReceive(animationTimer) { _ in
                                        animationTrigger.toggle()
                                    }
                            } else { // isAnimating が false (タップ後)
                                // 画像メッセージの場合
                                if message.isPicture, let text = dialogue.dialogueText {
                                    Image(text) //
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250, height: 250)
                                        .cornerRadius(16)
                                        .padding(.bottom, 8)
                                    //                                             .scaleEffect(message.textIsVisible ? 1.0 : 0.8, anchor: .bottomTrailing) // ← anchor 修正
                                    //                                             .opacity(message.textIsVisible ? 1.0 : 0.0)
                                    //                                             .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                                        .onAppear { // ★スクロールのためだけに残す★
                                            DispatchQueue.main.async {
                                                withAnimation { proxy.scrollTo(message.id, anchor: .bottom) }
                                            }
                                        }
                                    // テキストメッセージの場合
                                } else if message.showText, let text = dialogue.dialogueText {
                                    RubyLabelRepresentable( //
                                        attributedText: text.replacingOccurrences(of: "<br>", with: "\n")
                                            .createRuby(font: .customFont(ofSize: 22), color: .black),
                                        font: .customFont(ofSize: 22),
                                        textColor: .black,
                                        textAlignment: .left, // ★ 右寄せでもテキスト自体は左揃えのまま ★
                                        targetWidth: 270
                                    )
                                    .padding(13) //
                                    .background(Color.white.opacity(1.0)) //
                                    .cornerRadius(16) //
                                    .frame(maxWidth: 450, alignment: .trailing) // ← alignment 修正
                                    .padding(.bottom, 8) //
                                    //                                        .scaleEffect(message.textIsVisible ? 1.0 : 0.8, anchor: .bottomTrailing) // ← anchor 修正
                                    //                                        .opacity(message.textIsVisible ? 1.0 : 0.0) //
                                    //                                        .animation(.easeOut(duration: 0.3), value: message.textIsVisible) //
                                    .onAppear { // ★スクロールのためだけに残す★
                                        DispatchQueue.main.async {
                                            withAnimation { proxy.scrollTo(message.id, anchor: .bottom) }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    characterIcon(for: dialogue.characterName ?? "", size: 48)
                        .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottom)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: message.imageIsVisible)
                        .onAppear { // ★アイコン表示時にトリガー★
                            DispatchQueue.main.async { // スクロールは即時
                                withAnimation { proxy.scrollTo(message.id, anchor: .bottom) }
                            }
                            if !message.imageIsVisible { // まだ表示されていなければアニメーション開始
                                withAnimation {
                                    if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                        chatMessages[index].imageIsVisible = true
                                        // musicplayer.playSE(fileName: "icon_SE") // コニー側はSE不要かも
                                    }
                                }
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .trailing) // ← alignment 修正
            }

            if !isRight { Spacer() }
        }
        .padding(.horizontal)
        .id(message.id)
    }

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

    private func handleChoiceSelected(selectedText: String, nextId: String, percentage: Double?) {

            // 1. 選択肢プロンプトの情報を取得 (背景などを引き継ぐため)
            guard let triggeringChoice = currentChoiceDialogue else {
                print("エラー: handleChoiceSelected で currentChoiceDialogue が nil です。")
                // ポップアップを閉じて処理中断 (エラーハンドリング)
                isPopupVisible = false
                return
            }

            // 2. ユーザーが選んだ返信を表す newDialogue を作成
            // ★ StoryProgressView の replyScene と同様のデータを作成 ★
            let newDialogue = Dialogue2(
                storyId: triggeringChoice.storyId,          // 元のstoryId
                sceneId: "user_reply_\(UUID())",          // 一意のID
                viewType: .dialogue,                     // 返信なので .dialogue タイプにする (見た目はChatだが履歴上)
                characterName: "コニー",                   // ユーザー
                dialogueText: selectedText,                // 選んだテキスト
                nextSceneId: nextId,                      // 次に進むID
                isChoice: false,
                // --- 背景やキャラクター情報を引き継ぐ ---
                background: triggeringChoice.background,
                talkingPeople: triggeringChoice.talkingPeople,
                leftCharacter: triggeringChoice.leftCharacter,
                centerCharacter: triggeringChoice.centerCharacter,
                rightCharacter: triggeringChoice.rightCharacter,
                oneCharacter: triggeringChoice.oneCharacter,
                twoCharacter: triggeringChoice.twoCharacter,
                onePerson: triggeringChoice.onePerson,
                bgm: triggeringChoice.bgm
            )

            // 3. 画面上の最後のメッセージ (入力待ちアニメーション) を置き換える
            if let lastMessageIndex = chatMessages.indices.last {
                chatMessages[lastMessageIndex] = ChatMessage2(
                    dialogue: newDialogue, // ★ 作成した newDialogue を使う ★
                    isAnimating: false,    // ← アニメーションなし
                    showText: true,        // ← すぐ表示
                    imageIsVisible: true,  // ← アイコンもすぐ表示
                    textIsVisible: true   // ← テキストもすぐ表示
                )
            }

            // ★★★ ユーザーが選んだ返信を履歴に追加 ★★★
            print("履歴追加 (ChatMessage Choice): \(newDialogue.sceneId) - \(newDialogue.dialogueText ?? "")")
            conversationHistory.append(newDialogue)

            // 4. ポップアップを閉じる
            isPopupVisible = false
            currentChoiceDialogue = nil // 念のためクリア

            // 5. 次のシーンへ進む
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                proceedToNextIfNeeded()
            }
        }

    // メッセージのアニメーション完了時処理
    private func updateMessageState(id: UUID) {
        if let index = chatMessages.firstIndex(where: { $0.id == id }) {
            chatMessages[index].isAnimating = false
            chatMessages[index].showText = true
            chatMessages[index].textIsVisible = true
            scrollToBottom()

            // 次のメッセージへ進む
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                proceedToNextIfNeeded()
            }
        }
    }

    // 最下部スクロール補助
    private func scrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let last = chatMessages.last {
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy?.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    // 自動進行ロジック

    private func proceedToNextIfNeeded() {
        guard let last = chatMessages.last else { //
            print("proceedToNextIfNeeded: 最後のメッセージが見つかりません。")
            return
        }
        let nextId = last.dialogue.nextSceneId ?? "" //

        guard let next = dialogueMap[nextId] else {
            // ★★★ 修正箇所（ここから） ★★★

            // "end" を検出
            if nextId.lowercased() == "end" {
                print("proceedToNextIfNeeded: 'end' に到達しました。ユーザーのタップを待ちます。")
                // ★ onNextScene("end") を呼ばずに、ここで進行を停止する
                return
            }

            // "end" 以外で nextId があり、マップにない場合 (viewTypeの変更など)
            if !nextId.isEmpty {
                print("proceedToNextIfNeeded: 次のシーンID \(nextId) がマップにないため、親に通知します。")
                onNextScene(nextId)
            } else {
                print("proceedToNextIfNeeded: nextSceneIdが空です。")
            }
            // ★★★ 修正箇所（ここまで） ★★★
            return
        }

        // -------------------- 修正点 --------------------
        // 1. (先に) chat じゃない場合は親へ
        if next.viewType != .chat { //
            print("proceedToNextIfNeeded: 次はチャットではない(\(next.viewType))ため、親に通知します。")
            onNextScene(nextId) //
            return //
        }

        // 2. (先に) 主人公 ("コニー") の場合
        //    -> isChoice が true でも false でも、まず入力中アニメーションを表示
        if next.characterName == "コニー" { //
            print("proceedToNextIfNeeded: 次はコニーの番です。入力中アニメーションを表示します。")
            isTyping = true // ★アニメーション表示中は true に設定★
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //
                let newMsg = ChatMessage2( //
                    dialogue: next,
                    isAnimating: true,       // ★アニメーション表示★
                    showText: false,         // ★テキストはまだ★
                    imageIsVisible: false,   // ★アイコンもまだ★
                    textIsVisible: false     // ★吹き出しもまだ★
                )
                chatMessages.append(newMsg) //
//                conversationHistory.append(next) //
                scrollToBottom() //
                print("proceedToNextIfNeeded: コニーの入力中アニメーション用メッセージを追加。isTyping=\(isTyping)")
            }
            return // ★コニーの番はここで進行停止 (タップ待ち)★
        }

        // 3. (次に) 選択肢の場合 (コニー以外)
        if next.isChoice == true { //
            print("proceedToNextIfNeeded: 次は選択肢です。(コニー以外)")
            // isTyping = true // 選択肢表示中は isTyping を true にする必要はないかも？
            // 0.8秒待ってから選択肢前のメッセージ（通常は相手のメッセージのはず）を表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { //
                let choiceTriggerMsg = ChatMessage2( //
                    dialogue: next,
                    isAnimating: false, // 選択肢自体はアニメーション不要
                    showText: true,     // テキストはすぐ表示（"選択してください"など）
                    imageIsVisible: true, // アイコンもすぐ表示
                    textIsVisible: true   // 吹き出しもすぐ表示
                )
                chatMessages.append(choiceTriggerMsg) //
                conversationHistory.append(next) //
                scrollToBottom() // すぐスクロール

                // isTyping = false // 不要かも

                // さらに1.0秒後にポップアップを表示
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { //
                    currentChoiceDialogue = next //
                    isPopupVisible = true //
                    print("proceedToNextIfNeeded: 選択肢ポップアップを表示しました。")
                }
            }
            return // ★ 選択肢表示後は進行停止 ★
        }

        // 4. (最後に) 相手キャラの場合
        else { // 相手キャラのセリフは自動表示して続行
            print("proceedToNextIfNeeded: 次は相手(\(next.characterName ?? "不明"))の番です。")
            // isTyping = true // 相手の表示中は isTyping true である必要はない
            // 0.8秒待ってからメッセージ追加
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { //
                let newMsg = ChatMessage2( //
                    dialogue: next,
                    isAnimating: false,      // ★アニメーションは .onAppear でトリガー★
                    showText: true,          // ★テキスト内容は必要★
                    imageIsVisible: false,   // ★アイコンはまだ★
                    textIsVisible: false     // ★吹き出しはまだ★
                )
                chatMessages.append(newMsg) //
                conversationHistory.append(next) //
                scrollToBottom() // 追加したらすぐスクロール
                // isTyping = false // 不要
                print("proceedToNextIfNeeded: 相手のメッセージを追加。")

                // ★メッセージ表示アニメーション完了を見越して、さらに遅延させて次へ★
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // <- 1.2秒を少し長めに
                    print("proceedToNextIfNeeded: 相手のメッセージ表示後、次の進行をチェックします。")
                    proceedToNextIfNeeded() // 再帰呼び出し
                }
            }
        }
        // -------------------- 修正ここまで --------------------
    }
}

// MARK: - イベント処理
extension ChatMessageView {
    /// 初期化処理
    func initializeChat() {
        if let startDialogue = dialogue {
            let initialMsg = ChatMessage2(dialogue: startDialogue,
                                          isAnimating: false,
                                          showText: true,
                                          imageIsVisible: true,
                                          textIsVisible: true)
            chatMessages = [initialMsg]
            conversationHistory.append(startDialogue)

            // 最初に自動進行チェック
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                proceedToNextIfNeeded()
            }
        }
    }

    /// タップで次に進む
    func handleTap() {
        if isPopupVisible { return }

        guard let last = chatMessages.last else { return }

        // ★ 選択肢のアニメーション中ならポップアップを表示
        if last.dialogue.isChoice == true && last.isAnimating {
            isPopupVisible = true
            currentChoiceDialogue = last.dialogue
            return
        }

        // コニーのアニメーション中ならテキストを表示
        if last.dialogue.characterName == "コニー", last.isAnimating {
            updateMessageState(id: last.id)
            return
        }
    }

    func characterIcon(for name: String, size: CGFloat) -> some View {
        Image(getCharacterImageName(for: name))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    private func getCharacterImageName(for name: String) -> String {
        switch name {
        case "アレック": return "alec_icon"
        case "セシル": return "cecil_icon"
        case "コニー": return "cony_icon"
        case "ブライアン": return "brian_icon"
        case "カール": return "curl_icon"
        case "ケビン": return "kevin_icon"
        case "ロビー": return "robby_icon"
        case "サンドラ": return "sandra_icon"
        case "先生": return "teacher_icon"
        case "ニック": return "nick_icon"
        default: return "default_icon"
        }
    }

    /// 送信ボタンのアニメーション
    private func startLoopingAnimation() {
        withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
            isLarge = true
        }
    }
}
