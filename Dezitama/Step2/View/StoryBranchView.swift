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
                            case "chat":
//                            let _ =
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
                                isPopupVisible: $isPopupVisible
                            )

                        case "talk":
                            ZStack {
                                HStack {
//                                    話し手が1人だった時
                                    if !current.leftCharacter.isEmpty && current.rightCharacter.isEmpty {
                                        Spacer()
                                        Image(current.leftCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 500)
                                            .position(x: geometry.size.width/2,y: geometry.size.height * 0.5)
                                        Spacer()

                                    } else if current.leftCharacter.isEmpty && !current.rightCharacter.isEmpty {
                                        Spacer()

                                        Image(current.rightCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 500)
                                            .position(x: geometry.size.width/2,y: geometry.size.height * 0.5)
                                        Spacer()
                                    } else {
                                        Image(current.leftCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 450)

                                        Image(current.rightCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 450)
                                    }
                                }

                                Group{
//                                     吹き出し背景
                                    Image(current.speechBubble)
                                        .resizable()
                                        .frame(width: 950, height: 250)
                                        .offset(x:-13, y: 0)
                                        .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.8)

//                                     キャラ名ラベル
                                    Text(CharacterName(rawValue: current.characterName)?.displayName ?? current.characterName)
                                        .font(.system(size: 35))
                                        .font(.title)
                                        .padding(6)
                                        .cornerRadius(8)
                                        .position(x: geometry.size.width * 0.22,y: geometry.size.height * 0.673)

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
                    Spacer()
                    VStack {
                        Button {
                            path.removeLast()
                        }label: {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(.top, 0)
//                        .overlay{
//                            // isGrayOutがtrueの時にグレーアウト
//                            Color.black.opacity(isPopupVisible ? 0.45 : 0)
//                        }
                        }
                        Spacer()
                    }
                }


                if isPopupVisible, let choiceScene = currentChoiceScene {
                    let _ = print("isChoiceViewを呼び出します。isPopupVisible: \(isPopupVisible), choiceSceneId: \(choiceScene.sceneId)")
                    isChoiceView(
                        isPopupVisible: $isPopupVisible,
                        allScene: .constant(choiceScene),
                        onCorrectChoice: {
                            // 正解した後の次のシーンに遷移するロジック
                            self.currentSceneId = choiceScene.nextSceneId
                            self.currentChoiceScene = nil // ポップアップを非表示にした後、状態をリセット
                        }
                    )
                }

            }
            .onAppear {
                if let first = allBranchings.first {
                    currentSceneId = first.sceneId
                    startTyping(fullText: first.text)
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
