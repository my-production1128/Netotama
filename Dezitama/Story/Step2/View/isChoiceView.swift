//
//  isChoiceView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/06/25.
//
import SwiftUI

enum Choice: String {
    case choice1
    case choice2
    case choice3
}

struct isChoiceView: View {
    @State private var showCorrectMark: Bool = false
    @State private var selectedChoice: Choice? = nil
    @State private var isChoiceMade = false

//    選択肢のポイント用
    @EnvironmentObject private var gameManager: GameManager
    @EnvironmentObject var musicplayer: SoundPlayer

    @Binding var isPopupVisible: Bool
    @Binding var allScene: Branching
    var onChoiceSelected: (String, String) -> Void


    var body: some View {
            ZStack {
                VStack(spacing: 30) {
                    Text("いい選択肢を選ぼう！")
                        .font(.custom("MPLUS1-Bold", size: 40))
                        .foregroundColor(.white)
                    //                    選択肢１のボタン
                    Button(action: {
                        musicplayer.playSE(fileName: "button_SE")
                        handleChoice(.choice1)
                    }){
                        RubyLabelRepresentable(
                            attributedText: allScene.choice1Text
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createRuby(font: .customFont(ofSize: 30), color: .black),
                            font: .customFont(ofSize: 30),
                            textColor: .black,
                            textAlignment: .left,
                            targetWidth: 500
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 530, height: 120)
                        .padding()
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice1))
                    .disabled(isChoiceMade)

                    //                    選択肢２のボタン
                    Button(action: {
                        musicplayer.playSE(fileName: "button_SE")
                        handleChoice(.choice2)
                    }) {
                        RubyLabelRepresentable(
                            attributedText: allScene.choice2Text
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createRuby(font: .customFont(ofSize: 30), color: .black),
                            font: .customFont(ofSize: 30),
                            textColor: .black,
                            textAlignment: .left,
                            targetWidth: 500
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 530, height: 120)
                        .padding()
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice2))
                    .disabled(isChoiceMade)

//                    選択肢３のボタン
                    Button(action: {
                        musicplayer.playSE(fileName: "button_SE")
                        handleChoice(.choice3)
                    }) {
                        RubyLabelRepresentable(
                            attributedText: allScene.choice3Text
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createRuby(font: .customFont(ofSize: 30), color: .black),
                            font: .customFont(ofSize: 30),
                            textColor: .black,
                            textAlignment: .left,
                            targetWidth: 500
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 530, height: 120)
                        .padding()
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice3))
                    .disabled(isChoiceMade)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.black.opacity(0.5)
                    .frame(width: 2000, height: 1000)
                    .edgesIgnoringSafeArea(.all)
            }
    }


    // isChoiceView.swift

        private func handleChoice(_ choice: Choice) {
            // 選択済みフラグを立てて、ボタンを即座に無効化
            isChoiceMade = true
            // タップしたボタンの色を即座に変更
            selectedChoice = choice

            // 選択肢の情報を取得
            let selectedText: String?
            let nextId: String?
            let percentage: Double?

            switch choice {
            case .choice1:
                selectedText = allScene.choice1Text
                nextId = allScene.choice1NextSceneId
                percentage = allScene.choice1Percentage
            case .choice2:
                selectedText = allScene.choice2Text
                nextId = allScene.choice2NextSceneId
                percentage = allScene.choice2Percentage
            case .choice3:
                selectedText = allScene.choice3Text
                nextId = allScene.choice3NextSceneId
                percentage = allScene.choice3Percentage
            }

            print("🔵 選択肢を選びました！読み込んだパーセンテージ: \(percentage ?? -1.0)")

            let willGaugeIncrease = (percentage ?? 0.0) > 0.0

            // 2. 条件に応じて遅延時間を設定 (BadChoiceView と同じロジック)
            let delay: TimeInterval = willGaugeIncrease ? 2.0 : 0.7

            print("   - ゲージは増加しますか？: \(willGaugeIncrease)")
            print("   - 遅延時間を \(delay) 秒に設定します")

            // --- ▲▲▲ ここまでが変更点です ▲▲▲ ---


            if let text = selectedText, let id = nextId {
                // スコア加算は遅延の前に行う
                gameManager.addScore(percentage: percentage)

                // 3. 上で定義した 'delay' 変数を使用
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    print("   - (\(delay)秒後) ポップアップを閉じ、onChoiceSelected を実行します") // デバッグ
                    isPopupVisible = false
                    // 親ビューに選択されたテキストと次のシーンIDを渡す
                    onChoiceSelected(text, id)
                }
            }
        }

    struct CustomButtonStyle: ButtonStyle {
        var isSelected: Bool

        let defaultBackgroundColor = Color(red: 0.992, green: 0.925, blue: 0.824) // #FDECD2
        let selectedBackgroundColor = Color(red: 1.0, green: 0.737, blue: 0.251) // #FFBC40

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(isSelected || configuration.isPressed ? selectedBackgroundColor : defaultBackgroundColor)
                .cornerRadius(35)
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        }
    }

}
