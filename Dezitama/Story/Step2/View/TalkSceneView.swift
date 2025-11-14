//
//  TalkSceneView.swift (StoryBranchView.swiftファイル内に追加)
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/27.
//

import SwiftUI

struct TalkSceneView: View {

    // MARK: - Properties

    let current: Branching
    let geometry: GeometryProxy
    let talkFont: UIFont
    let branchingMap: [String: Branching]
    let offsetY: CGFloat
    let startLoopingAnimation: () -> Void

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


                        // MARK: 吹き出しとテキスト
                        Group{
                            let sceneDataForBubble: Branching? = isPopupVisible ? branchingMap[currentSceneId] : current

                            // sceneDataForBubbleがnilでない場合のみ表示
                            if let displayData = sceneDataForBubble {

                                // 吹き出し背景 (常に表示)
                                Image("speech_bubble_beige")
                                    .resizable()
                                    .frame(width: 950, height: 250)
                                    .offset(x:-13, y: 0)
                                    .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.8)

                                // キャラ名ラベル (表示データを参照)
                                let characterNameText = CharacterName(rawValue: displayData.characterName)?.displayName ?? displayData.characterName
                                Text(characterNameText)
                                    .font(.custom("MPLUS1-Regular", size: 35))
                                    .font(.title)
                                    .padding(6)
                                    .cornerRadius(8)
                                    .position(x: geometry.size.width * 0.22,y: geometry.size.height * 0.677)

                                // テキスト（会話文） (isPopupVisibleで表示方法を切り替え)
                                if isPopupVisible {
                                    // 🔽 isPopupVisibleがtrue: 前のシーンのテキストをアニメーションなしで表示 🔽
                                    WideRubyLabelRepresentable(
                                        attributedText: displayData.text // 前のシーンのテキスト
                                            .replacingOccurrences(of: "<br>", with: "\n")
                                            .createWideRuby(font: talkFont, color: .black),
                                        font: talkFont,
                                        textColor: .black,
                                        textAlignment: .natural, // または .left
                                        targetWidth: 500
                                    )
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: 700)
                                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)

                                } else {
                                    // 🔽 isPopupVisibleがfalse: 現在のシーンのテキストをアニメーションありで表示 🔽
                                    TypingRubyLabelRepresentable(
                                        attributedText: displayData.text // 現在のシーンのテキスト
                                            .replacingOccurrences(of: "<br>", with: "\n")
                                            .createWideRuby(font: talkFont, color: .black),
                                        charInterval: 0.05,
                                        font: talkFont,
                                        targetWidth: 500
                                    )
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: 700)
                                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)
                                }

                                // ナビゲーション (nextボタン - 変更なし、常に表示)
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

                            } else {
                                // データが見つからなかった場合のフォールバック (念のため)
                                 Text("表示エラー")
                                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)
                                    .foregroundColor(.red)
                            }
                        }
            .offset(y: 20)
        }
        .onAppear {
            let sceneToDisplay = currentChoiceScene ?? branchingMap[currentSceneId]
            if let current = sceneToDisplay {
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
    }

    private func handleTap() {
                if isPopupVisible {
                    return
                }

                // --- ▼▼▼ ここからが修正版の handleTap です ▼▼▼ ---

                let nextId: String
                let currentSceneIdForStack: String // historyStack に追加するID

                if let replyScene = currentChoiceScene {
                    // 1.【返信シーン】をタップした場合
                    print("--- 🔵 返信シーンがタップされました ---")
                    nextId = replyScene.nextSceneId
                    // 'current' (プロパティ) が返信シーン
                    currentSceneIdForStack = current.sceneId

                    self.currentChoiceScene = nil // 一時シーンをクリア

                } else {
                    // 2.【通常シーン】をタップした場合
                    print("--- 🔵 通常シーンがタップされました ---")
                    guard let currentScene = branchingMap[currentSceneId] else {
                        print("【エラー】現在のシーンID「\(currentSceneId)」がマップ内に見つかりません。")
                        return
                    }
                    nextId = currentScene.nextSceneId
                    // 'currentSceneId' (Binding) が通常シーン
                    currentSceneIdForStack = currentSceneId
                    print(currentScene.text)
                }

                // 3.【共通のシーン遷移ロジック】
                print("次のシーンID「\(nextId)」へ進もうとしています。")

                guard let nextScene = branchingMap[nextId] else {
                    // 'end' またはエラー
                    if nextId.lowercased() == "end" || nextId.isEmpty {
                        print("成績ボタンを表示")
                        // 'end' の場合、currentSceneId を 'end' に設定して親に通知する
                        self.currentSceneId = nextId
                    } else {
                        print("【エラー】次のシーンID「\(nextId)」がマップ内に見つかりません。CSVのIDが正しいか確認してください。")
                    }
                    // ★ 'end' の場合も必ずSEと履歴を追加する
                    musicplayer.playSE(fileName: "button_SE_2")
                    historyStack.append(currentSceneIdForStack)
                    return // 処理を終了
                }

                // 'nextId' が有効なシーンの場合
                print("✅ 次のシーン「\(nextId)」が見つかりました。タイプは「\(nextScene.sceneType)」です。")

                musicplayer.playSE(fileName: "button_SE_2")
                historyStack.append(currentSceneIdForStack) // 今 のシーンをスタックに追加


                // ▼▼▼【ここが修正箇所です】▼▼▼
                if nextScene.isChoice != true {
                    // 'nextId' が "school" ではない場合のみ、履歴に追加する
                    if nextScene.sceneType.lowercased() != "screen" {
                        conversationHistory.append(nextScene) // 次 のシーンを履歴に追加
                    } else {
                        print("--- 履歴スキップ: nextSceneId 'screen' は conversationHistory に追加しません ---")
                    }
                }
                // ▲▲▲【修正ここまで】▲▲▲


                // 4.【共通のナビゲーションロジック】
                if nextScene.sceneType.lowercased() == "talk" {
                    print("➡️ 次も talk シーンです。")
                    if nextScene.isChoice == true {
                        print("選択肢なのでポップアップを表示します。")
                        isPopupVisible = true
                        currentChoiceScene = nextScene
                    } else {
                        currentSceneId = nextScene.sceneId
                    }
                } else {
                    currentSceneId = nextScene.sceneId
                }

                // --- ▲▲▲ 修正ここまで ▲▲▲ ---
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
