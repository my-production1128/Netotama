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
}

struct isChoiceView: View {
    @State private var showCorrectMark: Bool = false
    @State private var explanation: Bool = false
    @State private var selectedChoice: Choice? = nil  // どちらの選択肢を選んだかを保存

    @Binding var isPopupVisible: Bool
    @Binding var allScene: Branching
    var onCorrectChoice: () -> Void


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
                        Text(allScene.choiceText1)
                            .font(.system(size: 30, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }.buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice1))

//                    選択肢２のボタン
                    Button(action: {
                        handleChoice(.choice2)
                    }) {
                        Text(allScene.choiceText2)
                            .font(.system(size: 30, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(CustomButtonStyle(isSelected: selectedChoice == .choice2))
                }

//                解説画面の表示
                if explanation {
                    ZStack {
                        VStack {
                            Image("blackboard")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 950, height: 650)
                        }.border(Color.black, width: 3)
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
    }

    private func handleChoice(_ choice: Choice) {
        selectedChoice = choice
        // 正解の文字列と比較
        let selectedText = (choice == .choice1) ? allScene.choiceText1 : allScene.choiceText2
        if selectedText == allScene.text {
            showCorrectMark = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showCorrectMark = false
                isPopupVisible = false
                onCorrectChoice()
            }
        } else {
            explanation = true
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
