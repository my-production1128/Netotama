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
    let scene: NetomoBranching
    var isAnimating: Bool = true
    var showText: Bool = false
}

struct ChatSceneView: View {
    let branchingMap: [String: NetomoBranching]
    let initialSceneId: String
    var onNextScene: (String) -> Void


    @State var isTyping = false
    @State var pendingMessage: NetomoBranching? = nil
//     アニメーションの表示
    @State var animationTrigger = true
    @State var chatMessage: [ChatMessage] = []
    @State private var triangleAnimationTrigger = false
    @State private var offsetY: CGFloat = 0.0
    @State var currentChoiceScene: NetomoBranching? = nil


//    scvファイル
    @Binding var netomoScene: NetomoBranching
    @Binding var netomoBranchings: [NetomoBranching]
//    選択肢のポップアップを表示する
    @Binding var isPopupVisible: Bool
//    @Binding var nextChat: Bool



    var color: Color = .blue
    var dotSize: CGFloat = 30
    var bounceHeight: CGFloat = 90
    var repeatCount: Int = 2
    
    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    VStack {
//                                        チャットの画面のスクロール部分
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
                            .frame(width: 500, height: 450)
//                            .background(Color.black.opacity(0.5))
                            .position(x: geometry.size.width  * 0.492,y: geometry.size.height * 0.45)
                            .onChange(of: chatMessage.count) {
                                withAnimation {
                                    if let last = chatMessage.last {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }


                    VStack{
                        Spacer()
                        Button {
                            skipAllChatScenes()
                        }label: {
                            Text("飛ばす")
                                .font(.system(size: 20, weight: .bold, design: .default))
                        }
                        HStack {
                            Spacer()
                            Image("next_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .padding(40)
                                .offset(y: offsetY)
                                .onAppear {
                                    startLoopingAnimation()
                                }
                                .onTapGesture {
//                                  タイピング中または選択肢表示中なら何もしない
                                    if isTyping || isPopupVisible {
//                                    print(" タイピング中または選択肢表示中なのでスキップ")
                                        return
                                    }

//                                     最後のメッセージが存在するか確認
                                    guard let last = chatMessage.last else {
//                                    print(" 最後のメッセージが見つかりません")
                                        return
                                    }

                                    let nextId = last.scene.nextSceneId

//                                     次のシーンが branchingMap に存在するか確認
                                    guard let next = branchingMap[nextId] else {
                                        print(" 次のシーンが見つかりません: \(nextId)")
                                        onNextScene(nextId) // 必要なら外部ハンドラーを呼ぶ
                                        return
                                    }
//                                     chat のシーンの場合
                                    if next.sceneType == "chat" {
                                        if next.characterName != next.rightCharacter/*ネトモ：カール*/ {
//                                             相手のセリフ（アニメーションあり）
                                            isTyping = true
                                            pendingMessage = next
                                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                                if let msg = pendingMessage {
                                                    let newMsg = ChatMessage(scene: msg)
                                                    chatMessage.append(newMsg)
                                                    netomoScene = msg  // 最新のシーンを更新
                                                }
                                                pendingMessage = nil
                                                isTyping = false
                                            }
                                        } else {
//                                             自分のセリフ（即時表示）
                                            let newMsg = ChatMessage(scene: next, isAnimating: false, showText: true)
                                            netomoScene = next //  最新のシーンを更新

                                            if next.isChoice == true {
                                                isPopupVisible = true // シーン追加・更新後に表示
//                                                chatMessage.append(newMsg)
                                                currentChoiceScene = next
                                            } else {
                                                chatMessage.append(newMsg)
                                            }
                                        }
                                    } else {
//                                         chat 以外のシーンなら外のハンドラに任せる
                                        onNextScene(nextId)
                                    }
                                }
                                .padding(.top, 10)
                        }
                    }

//                     選択肢の問題を出す
                    if isPopupVisible, let choiceScene = currentChoiceScene {
                        isChoiceView(
                            isPopupVisible: $isPopupVisible,
                            netomoscene: .constant(choiceScene),
                            onCorrectChoice: {
                                let newMsg = ChatMessage(scene: choiceScene, isAnimating: false, showText: true)
                                chatMessage.append(newMsg)
                                currentChoiceScene = nil
                            }
                        )
                    }
                }
                .onAppear {
//                                    最初のメッセージを表示させておく
                    if let first = branchingMap[initialSceneId] {
                        //                    messageStack = [first]
                        chatMessage = [ChatMessage(scene: first)]

                    }
                }
            }
    }

//    次へすすむ三角形のボタンのアニメーションをループさせる
    private func startLoopingAnimation() {
        let animation = Animation
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)

        withAnimation(animation) {
            offsetY = 8.0
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
                            SpringKeyframe(-0.15 * bounceHeight, duration: 0.6)
                            SpringKeyframe(0.0, duration: 0.8)
                        }
                    }
            }
        }
    }
    
    
//与えられたチャットメッセージに応じて、
//ユーザー発言 or 相手発言の表示ビューを構築する。
//ユーザーの発言：右寄せで即時表示（青背景）
//相手の発言：左寄せでドットアニメーションのあとにテキスト表示（緑背景）
//アニメーションが必要な場合は `typingAnimationView()` を表示し、
//指定時間後にテキストへ切り替える。
    @ViewBuilder
    func messageRow(for message: ChatMessage) -> some View {
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
                                .font(.system(size: 18))
                                .foregroundColor(Color.gray)

                            if message.isAnimating {
                                typingAnimationView()
                                    .padding(22)
                                    .font(.system(size: 22))
                                    .background(Color.white.opacity(1.0))
//                                                                .frame(alignment: .leading)
                                    .cornerRadius(16)
                                    .onAppear {
//                                         最初のアニメーション
                                        animationTrigger.toggle()

//                                         1回目のアニメーション時間（2.5秒）後に再トリガー
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                                            animationTrigger.toggle()
                                        }

//                                         2回目の終了後にテキスト表示を実行
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                            withAnimation {
                                                updateMessageState(id: message.id)
                                            }
                                        }
                                    }
                            }

//                            ルビつきでテキストを表示
                            if message.showText {
                                RubyLabelRepresentable(
                                    attributedText: scene.text.replacingOccurrences(of: "<br>", with: "\n").createRuby(),
                                    font: .systemFont(ofSize: 22),
                                    textColor: .black,
                                    textAlignment: .left
                                )
                                .padding(13)
                                .background(Color.white.opacity(1.0))
                                .cornerRadius(16)
                                .frame(maxWidth: 350, alignment: .leading)                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)

                }
            } else {
                HStack(alignment: .top){
                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(CharacterName(rawValue: scene.characterName)?.displayName ?? scene.characterName)
                            .font(.system(size: 18))
                            .foregroundColor(Color.gray)


//                        ルビ付きでテキストを表示
                        RubyLabelRepresentable(
                            attributedText: scene.text.replacingOccurrences(of: "<br>", with: "\n").createRuby(),
                            font: .systemFont(ofSize: 22),
                            textColor: .black,
                            textAlignment: .left,
                        )
                        .font(.system(size: 22))
                        .padding(13)
                        .background(Color.white.opacity(1.0))
                        .cornerRadius(16)
                        .frame(maxWidth: 350, alignment: .trailing)
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


    private func skipAllChatScenes() {
        guard let last = chatMessage.last else { return }
        var nextId = last.scene.nextSceneId

        while let next = branchingMap[nextId], next.sceneType == "chat" {
            nextId = next.nextSceneId
        }

        onNextScene(nextId)  // 最初の非チャットシーンに移動
    }
}
