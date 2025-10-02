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
    @State private var isChatLogVisible: Bool = false
    
    // 選択肢の状態管理
    @State private var selectedChoice: Int? = nil
    @State private var isChoiceMade = false
    
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
         conversationHistory: Binding<[Dialogue2]>) {
        
        self.dialogues = dialogues
        self.initialSceneId = initialSceneId
        self.onNextScene = onNextScene
        self._currentSceneId = State(initialValue: initialSceneId)
        self._path = path
        self._conversationHistory = conversationHistory
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
                            path.removeLast()
                        }) {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        
                        // 会話見返し
                        Button(action: {
                            isChatLogVisible.toggle()
                        }) {
                            Image("chat")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .padding(20)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // スコアゲージ
                    VStack {
                        Gauge(width: geometry.size.width * 0.3,
                              height: 100,
                              score: gameManager.currentScore)
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
                    .position(x: geometry.size.width * 0.7,
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
        let dialogue = message.dialogue
        
        // 選択肢の場合
        if dialogue.isChoice == true {
            choiceView(for: message)
        } else {
            // 通常のメッセージ
            normalMessageView(for: message)
        }
    }
    
    @ViewBuilder
    private func choiceView(for message: ChatMessage2) -> some View {
        let dialogue = message.dialogue
        
        VStack(spacing: 20) {
            Text("あなたなら何て言う?")
                .font(.custom("MPLUS1-Bold", size: 28))
                .foregroundColor(.white)
                .padding(.top, 10)
            
            VStack(spacing: 15) {
                // 選択肢1
                if let choice1Text = dialogue.choice1Text {
                    Button(action: {
                        handleChoice(1, for: message)
                    }) {
                        RubyLabelRepresentable(
                            attributedText: choice1Text
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createRuby(font: .customFont(ofSize: 24), color: .black),
                            font: .customFont(ofSize: 24),
                            textColor: .black,
                            textAlignment: .left
                        )
                        .frame(width: 400)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(ChoiceButtonStyle(isSelected: selectedChoice == 1))
                    .disabled(isChoiceMade)
                }
                
                // 選択肢2
                if let choice2Text = dialogue.choice2Text {
                    Button(action: {
                        handleChoice(2, for: message)
                    }) {
                        RubyLabelRepresentable(
                            attributedText: choice2Text
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createRuby(font: .customFont(ofSize: 24), color: .black),
                            font: .customFont(ofSize: 24),
                            textColor: .black,
                            textAlignment: .left
                        )
                        .frame(width: 400)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(ChoiceButtonStyle(isSelected: selectedChoice == 2))
                    .disabled(isChoiceMade)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
        .padding(.horizontal)
        .scaleEffect(message.imageIsVisible ? 1.0 : 0.8)
        .opacity(message.imageIsVisible ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.3), value: message.imageIsVisible)
        .onAppear {
            if let index = chatMessages.firstIndex(where: { $0.id == message.id }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    chatMessages[index].imageIsVisible = true
                    scrollToBottom()
                }
            }
        }
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
    
    // 選択肢処理
    private func handleChoice(_ choiceNumber: Int, for message: ChatMessage2) {
        isChoiceMade = true
        selectedChoice = choiceNumber
        
        let dialogue = message.dialogue
        let nextId: String?
        let choiceText: String?
        let percentage: String?
        
        switch choiceNumber {
        case 1:
            nextId = dialogue.choice1NextSceneId
            choiceText = dialogue.choice1Text
            percentage = dialogue.choice1Percentage
        case 2:
            nextId = dialogue.choice2NextSceneId
            choiceText = dialogue.choice2Text
            percentage = dialogue.choice2Percentage
        default:
            return
        }
        
        print("🔵 選択肢\(choiceNumber)を選びました！パーセンテージ: \(percentage ?? "nil")")
        
        // 選択したテキストをコニーのメッセージとして追加
        if let text = choiceText, let next = nextId {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                // 選択したメッセージを追加
//                let chosenDialogue = Dialogue2(
//                    sceneId: "choice_\(UUID())",
//                    viewType: .chat,
//                    characterName: "コニー",
//                    dialogueText: text,
//                    nextSceneId: next
//                )
//                let chosenMsg = ChatMessage2(
//                    dialogue: chosenDialogue,
//                    isAnimating: false,
//                    showText: true,
//                    imageIsVisible: true,
//                    textIsVisible: true
//                )
//                self.chatMessages.append(chosenMsg)
//                self.conversationHistory.append(chosenDialogue)
//                self.scrollToBottom()
//                
//                // 次のシーンへ
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                    self.currentSceneId = next
//                    self.isChoiceMade = false
//                    self.selectedChoice = nil
//                    
//                    // 次のシーンが chat なら続行
//                    if let nextDialogue = self.dialogueMap[next] {
//                        if nextDialogue.viewType == .chat {
//                            self.proceedToNextIfNeeded()
//                        } else {
//                            self.onNextScene(next)
//                        }
//                    } else {
//                        self.onNextScene(next)
//                    }
//                }
//            }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let newMsg = ChatMessage2(dialogue: next,
                                          isAnimating: false,
                                          showText: true,
                                          imageIsVisible: false,
                                          textIsVisible: false)
                chatMessages.append(newMsg)
                conversationHistory.append(next)
                scrollToBottom()
                isTyping = false
            }
            return
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
        guard let last = chatMessages.last else { return }
        
        // コニーのアニメーション中ならテキストを表示
        if last.dialogue.characterName == "コニー", last.isAnimating {
            updateMessageState(id: last.id)
            return
        }
        
        // それ以外は何もしない（自動進行に任せる）
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

// MARK: - 選択肢ボタンスタイル
struct ChoiceButtonStyle: ButtonStyle {
    var isSelected: Bool
    
    let defaultBackgroundColor = Color(red: 0.992, green: 0.925, blue: 0.824)
    let selectedBackgroundColor = Color(red: 1.0, green: 0.737, blue: 0.251)
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(isSelected || configuration.isPressed ? selectedBackgroundColor : defaultBackgroundColor)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
