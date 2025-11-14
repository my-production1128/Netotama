//
//  BadChoiceView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/10/01.
//
import SwiftUI

struct BadChoiceView: View {
    let dialogue: Dialogue2
    @Binding var isPopupVisible: Bool
    var onChoiceSelected: (String, String, Double?) -> Void
    @EnvironmentObject private var gameManager: GameManager
    @EnvironmentObject var musicplayer: SoundPlayer

    @State private var selectedChoice: Int? = nil
    @State private var isChoiceMade = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    let titleText = "｜悪《わる》い｜選択肢《せんたくし》を｜選《えら》ぼう！"
                    let titleFont = UIFont(name: "MPLUS1-Bold", size: 40) ?? UIFont.boldSystemFont(ofSize: 40)

                    RubyLabelRepresentable(
                        attributedText: titleText.createRuby(font: titleFont, color: .white),
                        font: titleFont,
                        textColor: .white,
                        textAlignment: .center,
                        targetWidth: 500
                    )


                    // 選択肢1
                    if let choice1Text = dialogue.choice1Text {
                        Button(action: {
                            musicplayer.playSE(fileName: "button_SE")
                            if !isChoiceMade {
                                handleChoice(1)
                            }
                        }) {
                            RubyLabelRepresentable(
                                attributedText: choice1Text
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
                        .buttonStyle(ChoiceButtonStyle(isSelected: selectedChoice == 1))
                        .disabled(isChoiceMade)
                    }

                    // 選択肢2
                    if let choice2Text = dialogue.choice2Text {
                        Button(action: {
                            musicplayer.playSE(fileName: "button_SE")
                            if !isChoiceMade {
                                handleChoice(2)
                            }
                        }) {
                            RubyLabelRepresentable(
                                attributedText: choice2Text
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
                        .buttonStyle(ChoiceButtonStyle(isSelected: selectedChoice == 2))
                        .disabled(isChoiceMade)
                    }
                }
            }
        }
    }

    // BadChoiceView.swift

    private func handleChoice(_ choiceNumber: Int) {
        guard !isChoiceMade else {
            print("既に選択済みです")
            return
        }

        isChoiceMade = true
        selectedChoice = choiceNumber

        let nextId: String?
        let choiceText: String?
        let percentage: Double?

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
            print("無効な選択肢番号: \(choiceNumber)")
            return
        }
        print("🔵 選択肢を選びました！読み込んだパーセンテージ: \(percentage ?? -1.0)")

        // --- ▼▼▼ ここからが変更点です ▼▼▼ ---

        // 1. ゲージが増える（＝アニメーションが再生される）かどうかを判断
        // (percentage が nil でない、かつ 0.0 より大きい場合)
        let willGaugeIncrease = (percentage ?? 0.0) > 0.0

        // 2. 条件に応じて遅延時間を設定
        let delay: TimeInterval = willGaugeIncrease ? 2.0 : 0.7

        print("   - ゲージは増加しますか？: \(willGaugeIncrease)")
        print("   - 遅延時間を \(delay) 秒に設定します")

        // --- ▲▲▲ ここまでが変更点です ▲▲▲ ---


        print("--- 🟣 BadChoiceView.handleChoice ---")
        print("   - 1. gameManager.addScore を呼び出します (アニメーション開始トリガー)")

        gameManager.addScore(percentage: percentage)

        if let text = choiceText, let id = nextId {
            // 3. printデバッグのメッセージも修正
            print("   - 2. \(delay)秒後に onChoiceSelected をスケジュールします")

            // 4. 上で定義した 'delay' 変数を使用
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                print("   - 3. (\(delay)秒後) onChoiceSelected を実行します (ポップアップが閉じるトリガー)")
                onChoiceSelected(text, id, percentage)
            }
        } else {
            print("選択肢データが不完全です")
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
            .cornerRadius(35)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
