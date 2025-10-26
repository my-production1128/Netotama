//
//  ChatSceneView.swift
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
    var isPicture: Bool = false
}

struct ChatSceneView: View {
    let branchingMap: [String: Branching]
    let initialSceneId: String
    let animationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    var onNextScene: (String) -> Void
    var width: CGFloat
    var height: CGFloat

    @EnvironmentObject var musicplayer: SoundPlayer


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

    var color: Color = .gray
    var dotSize: CGFloat = 30
    var bounceHeight: CGFloat = 90
    var repeatCount: Int = 2

    var body: some View {
            ZStack {
                Text(ChatMessage(scene: self.allScene).scene.groupName)
                    .position(x: width * 0.51, y: height * 0.15)
                    .font(.custom("MPLUS1-Medium", size: 24))
                VStack {
                    //                                                 チャットの画面のスクロール部分
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack{
                                ForEach(chatMessage) { message in
                                    messageRow(for: message, proxy: proxy)
                                        .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .frame(width: 450, height: 550)
                        .offset(x: 10, y: 30)
                        .onAppear {
                            self.proxy = proxy
                        }
                    }
                }


                //                    選択肢の問題を出す
                if isPopupVisible, let choiceScene = currentChoiceScene {
                    isChoiceView(
                        isPopupVisible: $isPopupVisible,
                        allScene: .constant(choiceScene),
                        onChoiceSelected: { selectedText, nextId in
                            if let lastMessageIndex = chatMessage.indices.last {

                                let existingScene = chatMessage[lastMessageIndex].scene

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
                                    text: selectedText,
                                    nextSceneId: nextId,
                                    isChoice: false,
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

                                chatMessage[lastMessageIndex].isAnimating = false
                                chatMessage[lastMessageIndex].showText = true
                                chatMessage[lastMessageIndex].scene = newScene
//                                conversationHistory[lastMessageIndex] = newScene
                                allScene = newScene

                                conversationHistory.append(newScene)
                            }

                            isPopupVisible = false
                            proceedToNextIfNeeded()
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                if isTyping || isPopupVisible {
                    return
                }

                if let lastMessageIndex = chatMessage.indices.last, chatMessage[lastMessageIndex].isAnimating {
                    if chatMessage[lastMessageIndex].scene.isChoice ?? false {
                        isPopupVisible = true
                        currentChoiceScene = chatMessage[lastMessageIndex].scene
                    } else {
                        chatMessage[lastMessageIndex].isAnimating = false
                        chatMessage[lastMessageIndex].showText = true

                        conversationHistory.append(chatMessage[lastMessageIndex].scene)

                        DispatchQueue.main.async {
                            if let last = chatMessage.last {
                                withAnimation {
                                    self.proxy?.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                            proceedToNextIfNeeded()
                    }
                    return
                }
                guard let last = chatMessage.last else { return }
                if last.scene.characterName != last.scene.rightCharacter && last.isAnimating {
                    return
                }
                let nextId = last.scene.nextSceneId
                if nextId.lowercased() == "end" {
                    return
                }
                guard let next = branchingMap[nextId] else {
                    onNextScene(nextId)
                    return
                }
                if next.sceneType.lowercased() == "chat" {
                    if next.characterName == next.rightCharacter {
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
                        proceedToNextIfNeeded()
                    }
                } else if next.sceneType.lowercased() == "chat_picture" {
                    if next.characterName == next.rightCharacter {
                        let newMsg = ChatMessage(scene: next, isAnimating: true, showText: false, isPicture: true)
                                chatMessage.append(newMsg)
                                allScene = newMsg.scene
                        DispatchQueue.main.async {
                            if let last = chatMessage.last {
                                withAnimation {
                                    self.proxy?.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    } else {
                        let newMsg = ChatMessage(
                            scene: next,
                            isAnimating: true,
                            showText: false,
                            isPicture: true
                        )
                        chatMessage.append(newMsg)
                        allScene = newMsg.scene
                        DispatchQueue.main.async {
                            if let last = chatMessage.last {
                                withAnimation {
                                    self.proxy?.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                        proceedToNextIfNeeded()
                    }

                } else {
                    onNextScene(nextId)
                }
            }
            //                ↑ここまでonTapGestureの処理

            .onAppear {
                DispatchQueue.main.async {
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
                proceedToNextIfNeeded()

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

                            //                            ルビつきでテキストを表示
                            if message.isPicture {
                                Image(scene.text)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 250, height: 250)
                                    .cornerRadius(16)
                                    .padding(.bottom, 8)
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
                                                musicplayer.playSE(fileName: "icon_SE")
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

                            } else if message.showText {
                                RubyLabelRepresentable(
                                    attributedText: scene.text
                                        .replacingOccurrences(of: "<br>", with: "\n")
                                        .createRuby(font: .customFont(ofSize: 22), color: .black),
                                    font: .customFont(ofSize: 22),
                                    textColor: .black,
                                    textAlignment: .left,
                                    targetWidth: 270
                                )
                                .padding(13)
                                .background(Color.white.opacity(1.0))
                                .cornerRadius(16)
                                .frame(maxWidth: 450, alignment: .leading)
                                .padding(.bottom, 8)
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
                                            musicplayer.playSE(fileName: "icon_SE")
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
                                .padding(.bottom, 8)
                                .scaleEffect(message.textIsVisible ? 1.0 : 0.8, anchor: .bottomTrailing)
                                .opacity(message.textIsVisible ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.3), value: message.textIsVisible)
                                .onAppear {
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
                                            musicplayer.playSE(fileName: "icon_SE")
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
                        } else {
                            if message.isPicture {
                                Image(scene.text)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 250, height: 250)
                                    .cornerRadius(16)
                                    .padding(.bottom, 8)
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
                                                musicplayer.playSE(fileName: "icon_SE")
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
                            } else if message.showText {
                                RubyLabelRepresentable(
                                    attributedText: scene.text
                                        .replacingOccurrences(of: "<br>", with: "\n")
                                        .createRuby(font: .customFont(ofSize: 22), color: .black),
                                    font: .customFont(ofSize: 22),
                                    textColor: .black,
                                    textAlignment: .left,
                                    targetWidth: 270
                                )
                                .padding(13)
                                .background(Color.white.opacity(1.0))
                                .cornerRadius(16)
                                .frame(maxWidth: 450, alignment: .bottomTrailing)
                                .padding(.bottom, 8)
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
                                            musicplayer.playSE(fileName: "icon_SE")
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
        .id(message.id)
    }



    //自動返信の関数
    private func proceedToNextIfNeeded() {
        guard let last = chatMessage.last, !isTyping, !isPopupVisible else {
            return
        }

        let nextId = last.scene.nextSceneId

        if nextId.lowercased() == "end" {
                    print("ChatSceneView: 最後のメッセージ (\(last.scene.sceneId)) が表示完了。成績ボタン表示を依頼します。")
                    onNextScene("showResultButton")
                    return
                }

        guard let next = branchingMap[nextId] else {
            if nextId.lowercased() != "end" { onNextScene(nextId) }
            return
        }

        if next.sceneType != last.scene.sceneType {
            let isCurrentChat = last.scene.sceneType.lowercased() == "chat" || last.scene.sceneType.lowercased() == "chat_picture"
            let isNextChat = next.sceneType.lowercased() == "chat" || next.sceneType.lowercased() == "chat_picture"
            if isCurrentChat != isNextChat {
                 return
            }
        }

        if next.sceneType.lowercased() != "chat" && next.sceneType.lowercased() != "chat_picture" {
            onNextScene(nextId)
            return
        }

        if next.characterName.lowercased() == next.rightCharacter.lowercased() {
            isTyping = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let isPic = next.sceneType == "chat_picture"
                let newMsg = ChatMessage(scene: next, isAnimating: true, showText: false, isPicture: isPic)

                chatMessage.append(newMsg)
                allScene = next
                isTyping = false
            }
            return
        }

        if next.characterName != next.rightCharacter.lowercased() && next.sceneType.lowercased() == "chat" {
             isTyping = true
             pendingMessage = next
             DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                 if let msg = pendingMessage {
                     let newMsg = ChatMessage(scene: msg, isAnimating: false, showText: true)
                     chatMessage.append(newMsg)
                     conversationHistory.append(newMsg.scene)
                     allScene = msg
                 }
                 pendingMessage = nil
                 isTyping = false
                 proceedToNextIfNeeded()
             }
        }
    }
}
