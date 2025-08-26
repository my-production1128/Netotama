//
//  ChatView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/08/20.
//


import SwiftUI

// 一つのメッセージの情報を保持する構造体
struct GroupchatMessage: Identifiable {
    let id = UUID()
    let scene: Dialogue
    var isAnimating: Bool = true
    var showText: Bool = false
}

struct ChatView: View {
    // MARK: - Required Parameters
    let chatDialogues: [Dialogue] // Chat用のDialogue配列
    let onNextScene: () -> Void // 次のシーンへのコールバック
    
    // MARK: - Bindings
    @Binding var path: NavigationPath // ナビゲーションパス
    
    // MARK: - State Properties
    @State private var currentIndex = 0
    @State private var isTyping = false
    @State private var animationTrigger = true
    @State private var chatMessage: [GroupchatMessage] = []
    @State private var isLarge: Bool = false
    @State private var isShowingEndScreen = false
    @State private var autoProgressTimer: Timer? = nil // 自動進行用タイマー
        
    // 飛ばすボタン用の状態を追加
    @State private var shouldReturnToGroupchat = false
    
    // MARK: - Animation Constants
    private let color: Color = .blue
    private let dotSize: CGFloat = 30
    private let bounceHeight: CGFloat = 90
    private let talkFont = UIFont.customFont(ofSize: 22)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if shouldReturnToGroupchat {
                // 空のビューを表示してonNextSceneを呼び出す
                    Color.clear
                    .onAppear {
                        onNextScene()
                    }
                } else {
                    // 背景 - chatDialoguesの最初の要素からstoryIdを取得
                    if let firstDialogue = chatDialogues.first {
                        if firstDialogue.storyId == "groupchat" {
                            CommonUIComponents.backgroundImage("chat_gurutama")
                        } else if firstDialogue.storyId == "Netomo" {
                            CommonUIComponents.backgroundImage("chat_netotama")
                        } else if firstDialogue.storyId == "Kakusan" {
                            CommonUIComponents.backgroundImage("chat_potitama")
                        }
                    }
                    
                    // チャット表示エリア
                    chatDisplayArea(geometry: geometry)
                    
                    // 送信ボタン
                    sendButton(geometry: geometry)
                    
                    // デバッグ用スキップボタン
    //                skipButton
                    
                    // オーバーレイボタン
                    overlayButtons
                }
            }
            .onAppear {
                initializeChat()
            }
            .onDisappear {
                cancelAutoProgress()
            }
        }
    }
    
    // MARK: - View Components
    private func chatDisplayArea(geometry: GeometryProxy) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(chatMessage) { message in
                        messageRow(for: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .padding(.bottom, 10)
            .frame(width: 500, height: 455)
            .position(
                x: geometry.size.width * 0.492,
                y: geometry.size.height * 0.5
            )
            .onChange(of: chatMessage.count) {
                withAnimation {
                    if let last = chatMessage.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private func sendButton(geometry: GeometryProxy) -> some View {
        Button {
            handleSendButtonTap()
        } label: {
            Image("soushin")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .padding(40)
                .scaleEffect(isLarge ? 0.93 : 1)
        }
        .onAppear {
            startLoopingAnimation()
        }
        .position(
            x: geometry.size.width * 0.66,
            y: geometry.size.height * 0.9
        )
    }
    
//    private var skipButton: some View {
//        VStack {
//            HStack {
//                Spacer()
//                Button {
//                    shouldReturnToGroupchat = true
//                } label: {
//                    Text("飛ばす")
//                        .font(.system(size: 20, weight: .bold))
//                        .padding(10)
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//                .border(Color.yellow, width: 3)
//                .offset(x:0,y:0)
//            }
//            Spacer()
//        }
//    }
    
    private var overlayButtons: some View {
        Group {
            homeButton
        }
    }
    
    private var homeButton: some View {
        HStack {
            Spacer()
            VStack {
                Button(action: { path.removeLast() }) {
                    Image("home")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 30)
                }
                Spacer()
            }
        }
    }
    
    // MARK: - Message Row
    
    @ViewBuilder
    func messageRow(for message: GroupchatMessage) -> some View {
        let scene = message.scene
        let isRightMessage = isRightSideMessage(scene)
        
        HStack {
            if isRightMessage { Spacer() }
            
            if !isRightMessage {
                // 左側メッセージ（相手）
                leftMessageView(message: message)
            } else {
                // 右側メッセージ（自分）
                rightMessageView(message: message)
            }
            
            if !isRightMessage { Spacer() }
        }
        .padding(.horizontal)
        .id(message.id)
    }
    
    private func leftMessageView(message: GroupchatMessage) -> some View {
        VStack {
            HStack(alignment: .top) {
                characterIcon(for: message.scene.characterName)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(getDisplayName(for: message.scene.characterName))
                        .font(.system(size: 18))
                        .foregroundColor(Color.gray)
                    
                    if message.isAnimating {
                        typingAnimationView()
                            .padding(22)
                            .background(Color.white.opacity(1.0))
                            .cornerRadius(16)
                            .onAppear {
                                startTypingAnimation(for: message.id)
                            }
                    }
                    
                    if message.showText {
                        messageTextView(text: message.scene.dialogueText)
                            .padding(13)
                            .background(Color.white.opacity(1.0))
                            .cornerRadius(16)
                            .frame(maxWidth: 350, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func rightMessageView(message: GroupchatMessage) -> some View {
        HStack(alignment: .top) {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(getDisplayName(for: message.scene.characterName))
                    .font(.system(size: 18))
                    .foregroundColor(Color.gray)
                
                messageTextView(text: message.scene.dialogueText)
                    .padding(13)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(16)
                    .frame(maxWidth: 350, alignment: .trailing)
            }
            
            characterIcon(for: message.scene.characterName)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func messageTextView(text: String) -> some View {
        RubyLabelRepresentable(
            attributedText: text
                .replacingOccurrences(of: "<br>", with: "\n")
                .createRuby(font: talkFont, color: .black),
            font: talkFont,
            textColor: .black,
            textAlignment: .left
        )
    }
    
    // MARK: - Animation Views
    
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
    
    // MARK: - Auto Progress Logic (統一された自動進行ロジック)
    
    /// 自動進行タイマーを設定する（統一されたエントリーポイント）
    private func scheduleAutoProgress(delay: TimeInterval) {
        // 既存のタイマーがあればキャンセル
        cancelAutoProgress()
        
        autoProgressTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            proceedToNextMessage()
        }
    }
    
    /// 自動進行タイマーをキャンセルする
    private func cancelAutoProgress() {
        autoProgressTimer?.invalidate()
        autoProgressTimer = nil
    }
    
    // MARK: - Helper Methods
    
    private func initializeChat() {
        // 最初のチャットメッセージのみを表示
        if let firstChatDialogue = chatDialogues.first {
            let message = GroupchatMessage(
                scene: firstChatDialogue,
                isAnimating: !isRightSideMessage(firstChatDialogue),
                showText: isRightSideMessage(firstChatDialogue)
            )
            chatMessage = [message]
            currentIndex = 0
            
            // 左側メッセージの場合のみ自動進行を設定（タイピングアニメーション完了を待つ）
            // 右側メッセージの場合は何もしない（送信ボタン待ち）
        }
    }
    
    private func handleSendButtonTap() {
        if isTyping {
            return
        }
        
        // 右側（自分）のメッセージの場合のみ送信ボタンで進む
        if let currentMessage = chatMessage.last,
           isRightSideMessage(currentMessage.scene) {
            cancelAutoProgress() // 念のため既存タイマーをキャンセル
            proceedToNextMessage()
        }
    }
    
    private func proceedToNextMessage() {
        // タイマーをクリア
        cancelAutoProgress()
        
        currentIndex += 1
        
        if currentIndex < chatDialogues.count {
            let nextDialogue = chatDialogues[currentIndex]
            let isRight = isRightSideMessage(nextDialogue)
            
            let newMessage = GroupchatMessage(
                scene: nextDialogue,
                isAnimating: !isRight,
                showText: isRight
            )
            
            chatMessage.append(newMessage)
            
            // 右側メッセージの場合は何もしない（送信ボタン待ち）
            // 左側メッセージの場合は、タイピングアニメーション完了後に自動進行
        } else {
            // チャット終了
            onNextScene()
        }
    }
    
    //アニメーションの時間設定
    private func startTypingAnimation(for messageId: UUID) {
        animationTrigger.toggle()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animationTrigger.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            updateMessageState(id: messageId)
        }
    }
    
    private func updateMessageState(id: UUID) {
        if let index = chatMessage.firstIndex(where: { $0.id == id }) {
            withAnimation {
                chatMessage[index].isAnimating = false
                chatMessage[index].showText = true
            }
            
            // テキスト表示後、読む時間を与えてから自動進行（統一されたロジックを使用）
            scheduleAutoProgress(delay: 2.0) // 2秒後に自動進行
        }
    }
    
    private func startLoopingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.7)) {
                isLarge.toggle()
            }
        }
    }
    
    // CSVの LeftChat/RightChat カラムに基づいてメッセージの位置を決定
    private func isRightSideMessage(_ dialogue: Dialogue) -> Bool {
        // CSVファイルでRightChatが"Yes"の場合は右側（自分）のメッセージ
        // ここでは仮にcharacterNameで判定（実際のCSVカラム値に応じて調整）
        return dialogue.rightChat == "Yes"
    }
    
    private func getDisplayName(for characterName: String) -> String {
        // キャラクター名の表示用変換
        switch characterName {
        case "アレック": return "アレック"
        case "セシル": return "セシル"
        case "コニー": return "コニー"
        case "ケビン": return "ケビン"
        case "ロビー": return "ロビー"
        case "サンドラ": return "サンドラ"
        case "ブライアン": return "ブライアン"
        case "ニック": return "ニック"
        default: return characterName
        }
    }
}
