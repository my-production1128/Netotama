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
            if let currentDialogue = dialogue {
                Text(currentDialogue.groupName ?? "")
                    .offset(x: 10,y: -270)
                    .font(.custom("MPLUS1-Medium", size: 24))
            }
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(chatMessages) { message in
                                messageRow(for: message, proxy: proxy)
                                    .id(message.id)
                            }
                        }
                    }
                    .frame(width: 420, height: 560)
                    .offset(x: 15, y: 55)
                    .frame(maxHeight: .infinity)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            DispatchQueue.main.async {
                if let startDialogue = dialogue {
                    // ★ chat_picture の場合は isPicture を true に設定
                    let isPic = (startDialogue.viewType == .chat_picture)
                    let initialMsg = ChatMessage2(
                        dialogue: startDialogue,
                        isAnimating: false,
                        showText: true,
                        imageIsVisible: true,
                        textIsVisible: true,
                        isPicture: isPic
                    )
                    chatMessages = [initialMsg]
                    conversationHistory.append(startDialogue)
                    DispatchQueue.main.async {
                        if let last = chatMessages.last {
                            withAnimation {
                                self.proxy?.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        proceedToNextIfNeeded()
                    }
                }
            }
        }
        .onTapGesture {
            if isPopupVisible {
                return
            }

            guard let lastMessage = chatMessages.last else {
                return
            }

            if lastMessage.dialogue.characterName == "コニー", lastMessage.isAnimating {
                if !gameManager.didShowChatTapHint {
                    gameManager.didShowChatTapHint = true
                    gameManager.saveProgress()
                }

                if lastMessage.dialogue.isChoice == true {
                    currentChoiceDialogue = lastMessage.dialogue
                    isPopupVisible = true
                }
                else {
                    print("--- 🔵 onTapGesture: 「コニー」の入力中バブルがタップされました (ID: \(lastMessage.id)) ---")
                                        print("   - 状態変更: isAnimating=false, showText=true にします")
                    if let index = chatMessages.firstIndex(where: { $0.id == lastMessage.id }) {
                        chatMessages[index].isAnimating = false
                        chatMessages[index].showText = true
                        chatMessages[index].textIsVisible = true

                        scrollToBottom()
                        isTyping = false

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            print("   - 0.1秒後: proceedToNextIfNeeded() を呼び出します")
                            proceedToNextIfNeeded()
                        }
                    }
                }
                return
            } else if !lastMessage.isAnimating {
                guard let nextId = lastMessage.dialogue.nextSceneId, !nextId.isEmpty else {
                    return
                }
                if nextId.lowercased() == "end" {
                    onNextScene("end")
                    return
                }
                if let next = dialogueMap[nextId] {
                    if next.viewType != .chat && next.viewType != .chat_picture {
                        onNextScene(nextId)
                    }
                }
            }
        }
    }
}

// MARK: - サブビュー
extension ChatMessageView {

    @ViewBuilder
    func messageRow(for message: ChatMessage2, proxy: ScrollViewProxy) -> some View {
        let _ = print("--- 🎨 messageRow: 描画します (ID: \(message.id)) ---")
                let _ = print("   - Character: \(message.dialogue.characterName ?? "N/A")")
                let _ = print("   - Text: \(message.dialogue.dialogueText ?? "N/A")")
                let _ = print("   - isAnimating: \(message.isAnimating)")
                let _ = print("   - showText: \(message.showText)")
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
                        .onAppear {
                            DispatchQueue.main.async {
                                withAnimation { proxy.scrollTo(message.id, anchor: .bottom) }
                            }
                            if !message.imageIsVisible {
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

                        // ★ 画像表示の場合
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
                                .onAppear {
                                    if !message.textIsVisible {
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
                            .onAppear {
                                if !message.textIsVisible {
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

            } else if isRight {
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(dialogue.characterName ?? "")
                            .font(.custom("MPLUS1-Regular", size: 18))
                            .foregroundColor(Color.gray)
                            .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottomTrailing)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.05), value: message.imageIsVisible)

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
                                    .onAppear {
                                        animationTrigger.toggle()
                                        if !message.textIsVisible {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                withAnimation {
                                                    if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                                        chatMessages[index].textIsVisible = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .onReceive(animationTimer) { _ in
                                        animationTrigger.toggle()
                                    }
                            } else {
                                // ★ 画像メッセージの場合
                                if message.isPicture, let text = dialogue.dialogueText {
                                    Image(text)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250, height: 250)
                                        .cornerRadius(16)
                                        .padding(.bottom, 8)
                                        .onAppear {
                                            DispatchQueue.main.async {
                                                withAnimation { proxy.scrollTo(message.id, anchor: .bottom) }
                                            }
                                        }
                                // テキストメッセージの場合
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
                                    .background(Color.white.opacity(1.0))
                                    .cornerRadius(16)
                                    .frame(maxWidth: 450, alignment: .trailing)
                                    .padding(.bottom, 8)
                                    .onAppear {
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
                        .onAppear {
                            DispatchQueue.main.async {
                                withAnimation { proxy.scrollTo(message.id, anchor: .bottom) }
                            }
                            if !message.imageIsVisible {
                                withAnimation {
                                    if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                        chatMessages[index].imageIsVisible = true
                                        musicplayer.playSE(fileName: "icon_SE")
                                    }
                                }
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
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
        print("--- 🔵 handleChoiceSelected: 選択肢が選ばれました (ID: \(currentChoiceDialogue?.sceneId ?? "N/A")) ---")
                print("   - 最後のメッセージを「\(selectedText)」に置き換えます")

        guard let triggeringChoice = currentChoiceDialogue else {
            isPopupVisible = false
            return
        }

        let newDialogue = Dialogue2(
            storyId: triggeringChoice.storyId,
            sceneId: "user_reply_\(UUID())",
            viewType: .dialogue,
            characterName: "コニー",
            dialogueText: selectedText,
            nextSceneId: nextId,
            isChoice: false,
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

        if let lastMessageIndex = chatMessages.indices.last {
            chatMessages[lastMessageIndex] = ChatMessage2(
                dialogue: newDialogue,
                isAnimating: false,
                showText: true,
                imageIsVisible: true,
                textIsVisible: true,
                isPicture: false
            )
        }

        print("履歴追加 (ChatMessage Choice): \(newDialogue.sceneId) - \(newDialogue.dialogueText ?? "")")
        conversationHistory.append(newDialogue)
        isPopupVisible = false
        currentChoiceDialogue = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            print("   - 0.8秒後: proceedToNextIfNeeded() を呼び出します")
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                proceedToNextIfNeeded()
            }
        }
    }

    private func scrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let last = chatMessages.last {
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy?.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }


    private func proceedToNextIfNeeded() {
        print("--- 🔄 proceedToNextIfNeeded: 自動進行チェック開始 ---")
        guard let last = chatMessages.last else {
            return
        }
        let nextId = last.dialogue.nextSceneId ?? ""
        guard let next = dialogueMap[nextId] else {
            if nextId.lowercased() == "end" {
                print("proceedToNextIfNeeded: 'end' に到達しました。ユーザーのタップを待ちます。")
                onNextScene("end")
                return
            }
            if !nextId.isEmpty {
                print("proceedToNextIfNeeded: 次のシーンID \(nextId) がマップにないため、親に通知します。")
                onNextScene(nextId)
            } else {
                print("proceedToNextIfNeeded: nextSceneIdが空です。")
            }
            return
        }

        // ★ chat と chat_picture の両方を許可
        if next.viewType != .chat && next.viewType != .chat_picture {
            print("proceedToNextIfNeeded: 次はチャットではない(\(next.viewType))ため、親に通知します。")
            return
        }
        
        if next.characterName == "コニー" {
            print("proceedToNextIfNeeded: 次はコニーの番です。入力中アニメーションを表示します。")
            print("   - ➡️ 追加（コニー）: isAnimating=true (ID: \(next.sceneId))")
            isTyping = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                // ★ chat_picture の場合は isPicture を true に
                let isPic = (next.viewType == .chat_picture)
                let newMsg = ChatMessage2(
                    dialogue: next,
                    isAnimating: true,
                    showText: false,
                    imageIsVisible: false,
                    textIsVisible: false,
                    isPicture: isPic
                )
                chatMessages.append(newMsg)
                if next.isChoice != true  {
                    conversationHistory.append(next)
                }
                scrollToBottom()
                if next.nextSceneId?.lowercased() == "end" {
                    print("proceedToNextIfNeeded: コニーの最後のセリフです。親に'end'を通知します。")
                    onNextScene("end")
                }
            }
//            if next.nextSceneId?.lowercased() != "end" {
//                return
//            }
            return
        }

        if next.isChoice == true {
            print("   - ➡️ 追加（相手の選択肢）: showText=true (ID: \(next.sceneId))")
            print("proceedToNextIfNeeded: 次は選択肢です。(コニー以外)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let choiceTriggerMsg = ChatMessage2(
                    dialogue: next,
                    isAnimating: false,
                    showText: true,
                    imageIsVisible: true,
                    textIsVisible: true,
                    isPicture: false
                )
                chatMessages.append(choiceTriggerMsg)
                conversationHistory.append(next)
                scrollToBottom()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    currentChoiceDialogue = next
                    isPopupVisible = true
                    print("proceedToNextIfNeeded: 選択肢ポップアップを表示しました。")
                }
            }
            return
        }

        else {
            print("proceedToNextIfNeeded: 次は相手(\(next.characterName ?? "不明"))の番です。")
            print("   - ➡️ 追加（相手のセリフ）: showText=true (ID: \(next.sceneId))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                // ★ chat_picture の場合は isPicture を true に
                let isPic = (next.viewType == .chat_picture)
                let newMsg = ChatMessage2(
                    dialogue: next,
                    isAnimating: false,
                    showText: true,
                    imageIsVisible: false,
                    textIsVisible: false,
                    isPicture: isPic
                )
                chatMessages.append(newMsg)
                conversationHistory.append(next)
                scrollToBottom()
                print("proceedToNextIfNeeded: 相手のメッセージを追加。")

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    print("proceedToNextIfNeeded: 相手のメッセージ表示後、次の進行をチェックします。")
                    proceedToNextIfNeeded()
                }
            }
        }
    }
}

// MARK: - イベント処理
extension ChatMessageView {
    func initializeChat() {
        if let startDialogue = dialogue {
            let isPic = (startDialogue.viewType == .chat_picture)
            let initialMsg = ChatMessage2(
                dialogue: startDialogue,
                isAnimating: false,
                showText: true,
                imageIsVisible: true,
                textIsVisible: true,
                isPicture: isPic
            )
            chatMessages = [initialMsg]
            conversationHistory.append(startDialogue)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                proceedToNextIfNeeded()
            }
        }
    }

    func handleTap() {
        if isPopupVisible { return }

        guard let last = chatMessages.last else { return }

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

    private func startLoopingAnimation() {
        withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
            isLarge = true
        }
    }
}
