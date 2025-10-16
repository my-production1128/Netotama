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

    @State private var selectedChoice: Int? = nil
    @State private var isChoiceMade = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("あなたなら何て言う?")
                        .font(.custom("MPLUS1-Bold", size: 40))
                        .foregroundColor(.white)
                    
                    // 選択肢1
                    if let choice1Text = dialogue.choice1Text {
                        Button(action: {
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
                                targetWidth: 270
                            )
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: 430, height: 120)
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(ChoiceButtonStyle(isSelected: selectedChoice == 1))
                        .disabled(isChoiceMade)
                    }
                    
                    // 選択肢2
                    if let choice2Text = dialogue.choice2Text {
                        Button(action: {
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
                                targetWidth: 270
                            )
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: 430, height: 120)
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(ChoiceButtonStyle(isSelected: selectedChoice == 2))
                        .disabled(isChoiceMade)
                    }
                }
            }
        }
    }
    
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
        
        print("選択肢\(choiceNumber)を選びました")
        print("  テキスト: \(choiceText ?? "nil")")
        print("  次のID: \(nextId ?? "nil")")
//        print("  パーセンテージ: \(percentage ?? "nil")")
        
        if let text = choiceText, let id = nextId {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
