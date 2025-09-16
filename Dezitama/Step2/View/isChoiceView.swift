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
    @State private var explanation: Bool = false
    @State private var selectedChoice: Choice? = nil  // どちらの選択肢を選んだかを保存

    @Binding var isPopupVisible: Bool
    @Binding var allScene: Branching
    var onChoiceSelected: (String, String) -> Void


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(0.45)
                    .ignoresSafeArea()
                VStack(spacing: 30) {
                    //                    選択肢１のボタン
                    Button(action: {
                        handleChoice(.choice1)
                    }){
                        RubyLabelRepresentable(
                            attributedText: allScene.choice1Text
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createRuby(font: .customFont(ofSize: 30), color: .black),
                            font: .customFont(ofSize: 30),
                            textColor: .white,
                            textAlignment: .left
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: geometry.size.width * 0.8)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice1))

                    //                    選択肢２のボタン
                    Button(action: {
                        handleChoice(.choice2)
                    }) {
                        RubyLabelRepresentable(
                            attributedText: allScene.choice2Text
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createRuby(font: .customFont(ofSize: 30), color: .black),
                            font: .customFont(ofSize: 30),
                            textColor: .white,
                            textAlignment: .left
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: geometry.size.width * 0.8)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice2))

//                    選択肢３のボタン
                    Button(action: {
                        handleChoice(.choice3)
                    }) {
                        RubyLabelRepresentable(
                            attributedText: allScene.choice3Text
                                .replacingOccurrences(of: "<br>", with: "\n")
                                .createRuby(font: .customFont(ofSize: 30), color: .black),
                            font: .customFont(ofSize: 30),
                            textColor: .white,
                            textAlignment: .left
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: geometry.size.width * 0.8)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice3))
                }
            }

            //                解説画面の表示
            if explanation {
                ZStack {
                    VStack {
                        Image("")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 850, height: 850)
                    }

                    Button(action: {
                        explanation = false
                    }) {
                        Image("story_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 100)
                    }.position(x: geometry.size.width * 0.8925, y: geometry.size.height * 0.9)
                }
            }

            //                丸を出す関数
            if showCorrectMark {
                Image("circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .transition(.scale)
                    .animation(.easeInOut(duration: 0.3), value: showCorrectMark)
            }
        }
    }


    private func handleChoice(_ choice: Choice) {
        // 選択肢の情報を取得
        let selectedText: String?
        let nextId: String?

        switch choice {
        case .choice1:
            selectedText = allScene.choice1Text
            nextId = allScene.choice1NextSceneId
        case .choice2:
            selectedText = allScene.choice2Text
            nextId = allScene.choice2NextSceneId
        case .choice3:
            selectedText = allScene.choice3Text
            nextId = allScene.choice3NextSceneId
        }

        if let text = selectedText, let id = nextId {
            isPopupVisible = false
            // 親ビューに選択されたテキストと次のシーンIDを渡す
            onChoiceSelected(text, id)
        }
    }

    struct CustomButtonStyle: ButtonStyle {
        var isSelected: Bool

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(isSelected || configuration.isPressed ? Color.red : Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        }
    }

}
