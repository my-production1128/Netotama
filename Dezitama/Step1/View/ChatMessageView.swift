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
}

// MARK: - チャットビュー本体
struct ChatMessageView: View {
    let dialogues: [Dialogue2]
    let initialSceneId: String
    var onNextScene: (String) -> Void
    
    @State private var currentSceneId: String
    @EnvironmentObject private var gameManager: GameManager
    
    // Path（ホーム戻る用）
    @Binding var path: NavigationPath
    
    // 状態管理
    @State private var chatMessages: [ChatMessage2] = []
    @State private var proxy: ScrollViewProxy?
    
    // アニメーション用
    @State private var isLarge = false
    @State private var isTyping = false
    
    // 会話見返し
    @Binding var conversationHistory: [Dialogue2]
    @Binding var currentMode: GameMode
    @State private var isChatLogVisible: Bool = false
    
    // ★ 選択肢のポップアップ管理
    @State private var isPopupVisible: Bool = false
    @State private var currentChoiceDialogue: Dialogue2? = nil
    
    // dialoguesをマップ化
    private var dialogueMap: [String: Dialogue2] {
        Dictionary(uniqueKeysWithValues: dialogues.map { ($0.sceneId, $0) })
    }
    
    // 現在のdialogue
    private var dialogue: Dialogue2? {
        dialogues.first(where: { $0.sceneId == currentSceneId })
    }
    
    // init
    init(dialogues: [Dialogue2],
         initialSceneId: String,
         onNextScene: @escaping (String) -> Void,
         path: Binding<NavigationPath>,
         conversationHistory: Binding<[Dialogue2]>,
         currentMode: Binding<GameMode>) {

        self.dialogues = dialogues
        self.initialSceneId = initialSceneId
        self.onNextScene = onNextScene
        self._currentSceneId = State(initialValue: initialSceneId)
        self._path = path
        self._conversationHistory = conversationHistory
        self._currentMode = currentMode
    }
    
    @State private var animationTrigger = true
    let animationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    var color: Color = .gray
    var dotSize: CGFloat = 30
    var bounceHeight: CGFloat = 90
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                if let background = dialogue?.background {
                    Image(background)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
                
                // 上部のUI
                HStack {
                    VStack {
                        // ホームボタン
                        Button(action: {
//                            path.removeLast()
                        }) {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // スコアゲージ
                    VStack {

                        HStack{
                            Spacer()
                        }
                        HStack{
                            Spacer()
                            
                            // 会話見返し
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

                        Gauge(width: geometry.size.width * 0.3,
                              height: 100,
                              score: gameManager.currentScore, currentMode: $currentMode)

                        Spacer()
                    }
                }
                
                // チャット本文
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(chatMessages) { message in
                                    messageRow(for: message)
                                        .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .frame(width: 500, height: 450)
                        .position(x: geometry.size.width * 0.5,
                                  y: geometry.size.height * 0.5)
                        .onAppear {
                            self.proxy = proxy
                        }
                    }
                }
                
                // 送信ボタン（アニメーション）
                Image("soushin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .padding(40)
                    .scaleEffect(isLarge ? 0.93 : 1)
                    .onAppear {
                        startLoopingAnimation()
                    }
                    .position(x: geometry.size.width * 0.68,
                              y: geometry.size.height * 0.9)
                
                // スキップボタン
                Button(action: {
                    skipToNextChoice()
                }) {
                    Text("選択肢までスキップ")
                        .font(.system(size: 18, weight: .bold))
                        .padding(12)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                }
                .position(x: geometry.size.width - 120,
                          y: geometry.size.height - 50)
                
                // Body の ZStack 内
                if isPopupVisible, let choiceDialogue = currentChoiceDialogue {
                    BadChoiceView(
                        dialogue: choiceDialogue,
                        isPopupVisible: $isPopupVisible,
                        onChoiceSelected: { selectedText, nextId, percentage in
                            handleChoiceSelected(selectedText: selectedText,
                                               nextId: nextId,
                                               percentage: percentage)
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .onAppear {
                initializeChat()
            }
            .onTapGesture {
                handleTap()
            }
        }
    }
}

// MARK: - サブビュー
extension ChatMessageView {
    
    @ViewBuilder
    func messageRow(for message: ChatMessage2) -> some View {
        // 選択肢のときもここでは描画しない
        normalMessageView(for: message)
    }
    
    @ViewBuilder
    private func normalMessageView(for message: ChatMessage2) -> some View {
        let dialogue = message.dialogue
        
        // コニーなら右側固定
        let isRight = (dialogue.characterName == "コニー")
                      || (dialogue.characterName == dialogue.rightCharacter)
        
        HStack {
            if isRight { Spacer() }
            
            // 左側（相手キャラ）
            if !isRight {
                HStack(alignment: .top) {
                    characterIcon(for: dialogue.characterName ?? "", size: 48)
                        .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottom)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: message.imageIsVisible)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dialogue.characterName ?? "")
                            .font(.custom("MPLUS1-Regular", size: 18))
                            .foregroundColor(.gray)
                        
                        if message.showText, let text = dialogue.dialogueText {
                            Text(text.replacingOccurrences(of: "<br>", with: "\n"))
                                .font(.custom("MPLUS1-Regular", size: 22))
                                .padding(13)
                                .background(Color.white)
                                .cornerRadius(16)
                                .frame(maxWidth: 350, alignment: .leading)
                                .scaleEffect(message.textIsVisible ? 1.0 : 0.8,
                                             anchor: .bottomLeading)
                                .opacity(message.textIsVisible ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                                .onAppear {
                                    if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                        chatMessages[index].imageIsVisible = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            chatMessages[index].textIsVisible = true
                                            scrollToBottom()
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            
            // 右側（主人公:コニー）
            if isRight {
                HStack(alignment: .top) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(dialogue.characterName ?? "")
                            .font(.custom("MPLUS1-Regular", size: 18))
                            .foregroundColor(.gray)
                        
                        // コニー専用 typingAnimation → 本文
                        if dialogue.characterName == "コニー" {
                            if message.isAnimating {
                                typingAnimationView()
                                    .padding(13)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .onAppear {
                                        if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                            chatMessages[index].imageIsVisible = true
                                        }
                                        scrollToBottom()
                                    }
                            }
                            else if message.showText, let text = dialogue.dialogueText {
                                Text(text.replacingOccurrences(of: "<br>", with: "\n"))
                                    .font(.custom("MPLUS1-Regular", size: 22))
                                    .padding(13)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .frame(maxWidth: 350, alignment: .trailing)
                                    .scaleEffect(message.textIsVisible ? 1.0 : 0.8,
                                                 anchor: .bottomTrailing)
                                    .opacity(message.textIsVisible ? 1.0 : 0.0)
                                    .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                                    .onAppear {
                                        if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                                            chatMessages[index].textIsVisible = true
                                            scrollToBottom()
                                        }
                                    }
                            }
                        }
                    }
                    
                    characterIcon(for: dialogue.characterName ?? "", size: 48)
                        .scaleEffect(message.imageIsVisible ? 1.0 : 0.0, anchor: .bottom)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: message.imageIsVisible)
                }
            }
            
            if !isRight { Spacer() }
        }
        .padding(.horizontal)
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
        .onReceive(animationTimer) { _ in
            animationTrigger.toggle()
        }
    }
    
    private func handleChoiceSelected(selectedText: String, nextId: String, percentage: String?) {
        // 1. スコア加算
        if let percentageStr = percentage, let percentageValue = Double(percentageStr) {
            gameManager.addScore(percentage: percentageValue)
        }
        
        // 2. 最後のメッセージを選択したテキストで置き換え（即表示）
        if let lastMessageIndex = chatMessages.indices.last {
            let newDialogue = Dialogue2(
                characterName: "コニー", // 主人公のセリフに変更
                dialogueText: selectedText, // 選択したテキスト
                nextSceneId: nextId,        // 次のシーンID
                isChoice: false             // もう選択肢ではない
            )
            
            chatMessages[lastMessageIndex] = ChatMessage2(
                dialogue: newDialogue,
                isAnimating: false,    // ← アニメーションなし
                showText: true,        // ← すぐ表示
                imageIsVisible: true,
                textIsVisible: true
            )
        }
        
        // 3. ポップアップを閉じる
        isPopupVisible = false
        
        // 4. 次のシーンへ進む（今まで通りの進行ルールを適用）
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
        guard let last = chatMessages.last else { return }
        let nextId = last.dialogue.nextSceneId ?? ""
        
        if isTyping { return }
        
        guard let next = dialogueMap[nextId] else {
            if !nextId.isEmpty { onNextScene(nextId) }
            return
        }
        
        // 選択肢の場合は表示して停止
        if next.isChoice == true {
            isTyping = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                // チャットに選択肢メッセージを追加
                let newMsg = ChatMessage2(
                    dialogue: next,
                    isAnimating: false,  // アニメーション不要
                    showText: true,      // すぐ表示
                    imageIsVisible: true,
                    textIsVisible: true
                )
                chatMessages.append(newMsg)
                conversationHistory.append(next)
                isTyping = false
                
                
                // 数秒後にポップアップを自動表示
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    currentChoiceDialogue = next
                    isPopupVisible = true
                }
            }
            return // ここで停止！
        }

        
        // chat じゃない場合は親へ
        if next.viewType != .chat {
            onNextScene(nextId)
            return
        }
        
        // コニーのセリフはアニメーション付きで追加（タップ待ち）
        if next.characterName == "コニー" {
            isTyping = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let newMsg = ChatMessage2(dialogue: next,
                                          isAnimating: true,
                                          showText: false,
                                          imageIsVisible: false,
                                          textIsVisible: false)
                chatMessages.append(newMsg)
                conversationHistory.append(next)
                isTyping = false
            }
            return
        }
        
        // 相手キャラのセリフは自動表示して続行
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let newMsg = ChatMessage2(dialogue: next,
                                      isAnimating: false,
                                      showText: true,
                                      imageIsVisible: false,
                                      textIsVisible: false)
            chatMessages.append(newMsg)
            conversationHistory.append(next)
            isTyping = false
            
            // 再帰的に次をチェック
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                proceedToNextIfNeeded()
            }
        }
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
    
    // 選択肢までスキップ
    func skipToNextChoice() {
        var nextId = currentSceneId
        var targetDialogue: Dialogue2?
        var messagesOnWay: [Dialogue2] = []
        
        while let next = dialogueMap[nextId], next.viewType == .chat {
            if next.isChoice == true {
                targetDialogue = next
                break
            }
            messagesOnWay.append(next)
            nextId = next.nextSceneId ?? ""
        }
        
        // スキップしたメッセージを追加
        for msg in messagesOnWay {
            let newMsg = ChatMessage2(dialogue: msg,
                                      isAnimating: false,
                                      showText: true,
                                      imageIsVisible: true,
                                      textIsVisible: true)
            chatMessages.append(newMsg)
            conversationHistory.append(msg)
        }
        
        // 選択肢も追加
        if let dialogue = targetDialogue {
            let choiceMsg = ChatMessage2(dialogue: dialogue,
                                         isAnimating: false,
                                         showText: true,
                                         imageIsVisible: true,
                                         textIsVisible: true)
            chatMessages.append(choiceMsg)
            conversationHistory.append(dialogue)
            scrollToBottom()
        }
    }
    
    /// 送信ボタンのアニメーション
    private func startLoopingAnimation() {
        withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
            isLarge = true
        }
    }
}

