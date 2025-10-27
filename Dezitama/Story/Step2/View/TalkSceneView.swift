//
//  TalkSceneView.swift (StoryBranchView.swiftファイル内に追加)
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/27.
//

import SwiftUI

struct TalkSceneView: View {

    // MARK: - Properties

    // 親Viewからのデータ
    let current: Branching
    let geometry: GeometryProxy
    let talkFont: UIFont
    let branchingMap: [String: Branching]
    let offsetY: CGFloat // "next"ボタンのアニメーション用
    let startLoopingAnimation: () -> Void // アニメーション開始用のクロージャ

    @State private var isAnimationReady: Bool = false

    // 親Viewと同期するState
    @Binding var currentSceneId: String
    @Binding var currentChoiceScene: Branching?
    @Binding var isPopupVisible: Bool
    @Binding var conversationHistory: [Branching]
    @Binding var historyStack: [String]

    // EnvironmentObject
    @EnvironmentObject var musicplayer: SoundPlayer

    // MARK: - Body

    var body: some View {
        ZStack {
            // MARK: キャラクター表示
            HStack(spacing: 0) {
                if !current.leftCharacter.isEmpty {
                    if current.centerCharacter.isEmpty && current.rightCharacter.isEmpty {
                        Spacer()
                    }

                    characterImage(
                        imageName: current.leftCharacter,
                        speakingCharacter: current.characterName
                    )
                    .frame(width: 350, height: 500)
                }

                if !current.centerCharacter.isEmpty {
                    if current.leftCharacter.isEmpty && current.rightCharacter.isEmpty {
                        Spacer()
                    }

                    characterImage(
                        imageName: current.centerCharacter,
                        speakingCharacter: current.characterName
                    )
                    .frame(width: 350, height: 500)

                    if current.leftCharacter.isEmpty && current.rightCharacter.isEmpty {
                        Spacer()
                    }
                }

                if !current.rightCharacter.isEmpty {
                    if current.leftCharacter.isEmpty && current.centerCharacter.isEmpty {
                        Spacer()
                    }

                    characterImage(
                        imageName: current.rightCharacter,
                        speakingCharacter: current.characterName
                    )
                    .frame(width: 350, height: 500)
                }

                // 4. 左・中央・右のすべてが表示されていない場合
                if current.leftCharacter.isEmpty && current.centerCharacter.isEmpty && current.rightCharacter.isEmpty {
                    Text("キャラクターが設定されていません")
                }
            }
            .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            Group{
                // 吹き出し背景
                Image("speech_bubble_beige")
                    .resizable()
                    .frame(width: 950, height: 250)
                    .offset(x:-13, y: 0)
                    .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.8)

                // キャラ名ラベル
                let characterNameText = CharacterName(rawValue: current.characterName)?.displayName ?? current.characterName
                Text(characterNameText)
                    .font(.custom("MPLUS1-Regular", size: 35))
                    .font(.title)
                    .padding(6)
                    .cornerRadius(8)
                    .position(x: geometry.size.width * 0.22,y: geometry.size.height * 0.677)

                // テキスト（会話文）
                TypingRubyLabelRepresentable(
                    attributedText: current.text
                        .replacingOccurrences(of: "<br>", with: "\n")
                        .createWideRuby(font: talkFont, color: .black),
                    charInterval: 0.05,
                    font: talkFont,
                    targetWidth: 500
                )
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 700)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)

                // ナビゲーション
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
        .onAppear {
            let sceneToDisplay = currentChoiceScene ?? branchingMap[currentSceneId]
            if let current = sceneToDisplay {
                musicplayer.stopAllMusic()
                musicplayer.playBGM(fileName: current.bgm)
            }
            isAnimationReady = false

            // テキストの文字数からタイピング完了時間を計算
                let textLength = current.text.replacingOccurrences(of: "<br>", with: "").count
                let typingDuration = Double(textLength) * 0.03 + 0.1

                // タイピング完了後にタップを有効化
                DispatchQueue.main.asyncAfter(deadline: .now() + typingDuration) {
                    isAnimationReady = true
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isAnimationReady else {
            return
        }
            if isAnimationReady {
                handleTap()
            }
        }
//        .onTapGesture {
//            // ポップアップ表示中はタップを無効にする
//            if isPopupVisible {
//                return
//            }
//
//            if let replyScene = currentChoiceScene {
//                let nextActualId = replyScene.nextSceneId
//                self.currentChoiceScene = nil // 一時シーンをクリア
//                self.currentSceneId = nextActualId
//                return
//            }
//
//            print("--- 🔵 talkシーンがタップされました ---")
//            print("文字の表示完了フラグ (isTypingComplete): \(isTypingComplete)")
//
//            if !isTypingComplete {
//                shouldSkipTyping = true
//                isTypingComplete = true
//                print("文字表示をスキップします。")
//            } else {
//                guard let current = branchingMap[currentSceneId] else {
//                    print("【エラー】現在のシーンID「\(currentSceneId)」がマップ内に見つかりません。")
//                    return
//                }
//
//                let nextId = current.nextSceneId
//                print("次のシーンID「\(nextId)」へ進もうとしています。")
//
//                guard let nextScene = branchingMap[nextId] else {
//                    if nextId.lowercased() == "end" || nextId.isEmpty {
//                        print("成績ボタンを表示")
//                    } else {
//                        print("【エラー】次のシーンID「\(nextId)」がマップ内に見つかりません。CSVのIDが正しいか確認してください。")
//                    }
//                    return
//                }
//
//                print("✅ 次のシーン「\(nextId)」が見つかりました。タイプは「\(nextScene.sceneType)」です。")
//
//                historyStack.append(currentSceneId)
//                if nextScene.isChoice != true {
//                    conversationHistory.append(nextScene)
//                }
//
//                if nextScene.sceneType.lowercased() == "talk" {
//                    print("➡️ 次も talk シーンです。")
//                    if nextScene.isChoice == true {
//                        print("選択肢なのでポップアップを表示します。")
//                        isPopupVisible = true
//                        currentChoiceScene = nextScene
//                    } else {
//                        print("通常のtalkシーンなので、IDを「\(nextScene.sceneId)」に更新します。")
//                        currentSceneId = nextScene.sceneId
//                    }
//                } else {
//                    print("➡️ talk 以外のシーン（\(nextScene.sceneType)）に切り替わります。")
//                    print("IDを「\(nextScene.sceneId)」に更新します。")
//                    currentSceneId = nextScene.sceneId
//                }
//            }
//        }
    }

    private func handleTap() {
            // ポップアップ表示中はタップを無効にする
            if isPopupVisible {
                return
            }

            if let replyScene = currentChoiceScene {
                let nextActualId = replyScene.nextSceneId
                self.currentChoiceScene = nil // 一時シーンをクリア
                self.currentSceneId = nextActualId
                return
            }

            print("--- 🔵 talkシーンがタップされました ---")

                guard let current = branchingMap[currentSceneId] else {
                    print("【エラー】現在のシーンID「\(currentSceneId)」がマップ内に見つかりません。")
                    return
                }

                let nextId = current.nextSceneId
                print("次のシーンID「\(nextId)」へ進もうとしています。")

                guard let nextScene = branchingMap[nextId] else {
                    if nextId.lowercased() == "end" || nextId.isEmpty {
                        print("成績ボタンを表示")
                    } else {
                        print("【エラー】次のシーンID「\(nextId)」がマップ内に見つかりません。CSVのIDが正しいか確認してください。")
                    }
                    return
                }

                print("✅ 次のシーン「\(nextId)」が見つかりました。タイプは「\(nextScene.sceneType)」です。")

                historyStack.append(currentSceneId)
                if nextScene.isChoice != true {
                    conversationHistory.append(nextScene)
                }

                if nextScene.sceneType.lowercased() == "talk" {
                    print("➡️ 次も talk シーンです。")
                    if nextScene.isChoice == true {
                        print("選択肢なのでポップアップを表示します。")
                        isPopupVisible = true
                        currentChoiceScene = nextScene
                    } else {
                        print("通常のtalkシーンなので、IDを「\(nextScene.sceneId)」に更新します。")
                        currentSceneId = nextScene.sceneId
                    }
                } else {
                    print("➡️ talk 以外のシーン（\(nextScene.sceneType)）に切り替わります。")
                    print("IDを「\(nextScene.sceneId)」に更新します。")
                    currentSceneId = nextScene.sceneId
                }

        }
}

@ViewBuilder
private func characterImage(imageName: String, speakingCharacter: String) -> some View {

    let isSpeaking = (speakingCharacter == imageName)

    let speakingScale: CGFloat = isSpeaking ? 1.1 : 1.0

    Image(imageName)
        .resizable()
        .scaledToFit()
        .scaleEffect(speakingScale)
        .saturation(isSpeaking ? 1.0 : 0.7)
        .brightness(isSpeaking ? 0.0 : -0.2)
        .animation(.easeInOut(duration: 0.3), value: isSpeaking)
}

private func getCharacterNameFromImage(_ imageName: String) -> String {
    let baseName = imageName.components(separatedBy: "_").first ?? imageName
    return CharacterName(rawValue: baseName)?.displayName ?? baseName
}
