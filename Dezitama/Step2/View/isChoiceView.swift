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

    @Binding var isPopupVisible: Bool
    @Binding var allScene: Branching
    var onChoiceSelected: (String, String) -> Void


    var body: some View {
//        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("あなたなら何て言う？")
                        .font(.custom("MPLUS1-Bold", size: 40))
                        .foregroundColor(.white)
                    //                    選択肢１のボタン
                    Button(action: {
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
                        .frame(width: 430, height: 120)
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice1))
                    .disabled(isChoiceMade)

                    //                    選択肢２のボタン
                    Button(action: {
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
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice2))
                    .disabled(isChoiceMade)

//                    選択肢３のボタン
                    Button(action: {
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
                        .frame(width: 430, height: 120)
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice3))
                    .disabled(isChoiceMade)
                }
            }

            //                丸を出す関数
            .overlay( // .overlay を使って上に重ねる
                ZStack {
                    if showCorrectMark {
                        Image("circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .transition(.scale)
                            .animation(.easeInOut(duration: 0.3), value: showCorrectMark)
                    }
                }
            )
//        }
    }


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

        if let text = selectedText, let id = nextId {
            // スコア加算は遅延の前に行う
            gameManager.addScore(percentage: percentage)

            // 0.5秒待ってから画面を閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
                .clipShape(Capsule())
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        }
    }

}
