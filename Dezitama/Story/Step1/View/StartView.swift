//
//  StartView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/24.
//
import SwiftUI

// MARK: - あらすじ画面
struct startView: View {
    let dialogue: Dialogue2
    var onNext: (String) -> Void

    // アニメーション用のState変数を追加
    @State private var viewOpacity: Double = 0.0
    @State private var isInteractable: Bool = false
    @State private var offsetY: CGFloat = 0.0

    @EnvironmentObject var musicplayer: SoundPlayer
    var body: some View {
        ZStack {
            // 背景
            Image("arasuzi_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            ZStack{
                if let dialogueText = dialogue.dialogueText {
                    WideRubyLabelRepresentable(
                        attributedText: dialogueText
                            .replacingOccurrences(of: "<br>", with: "\n")
                            .createWideRuby(font: UIFont.customFont(ofSize: 30), color: .black),
                        font: UIFont.customFont(ofSize: 30),
                        textColor: .black,
                        textAlignment: .center,
                        targetWidth: 700
                    )
                    .frame(maxWidth: 750)
                    .padding(.horizontal, 20)
                    .id(dialogueText)
                    .offset(y: -150)
                }


                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Button(action: handleTap) {
                            Image("next_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                                .offset(y: offsetY)
                                .onAppear {
                                    startLoopingAnimation()
                                }
                                .padding(80)
                        }
                        .padding()
                        .offset(y: -90)
                    }
                }
            }
            .opacity(viewOpacity)

        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            runFadeInAnimation()
        }
        .onChange(of: dialogue.dialogueText) {
            runFadeInAnimation()
        }
    }

    private func handleTap() {
        guard isInteractable else {
            print("startViewアニメーション中のためタップを無視しました。")
            return
        }

        guard let nextSceneId = dialogue.nextSceneId else {
            print("startView: nextSceneId がありません。")
            return
        }

        if nextSceneId.lowercased() == "end" {
            print("startView: 'end' を検出。親に通知します。")
            onNext("end")
            return
        }

        musicplayer.playSE(fileName: "button_SE_2")
        print("startView: 次のシーン \(nextSceneId) へ。親に通知します。")
        onNext(nextSceneId)
    }

    // ボタンアニメーション用の関数
    private func startLoopingAnimation() {
        offsetY = 0.0
        let animation = Animation
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)

        withAnimation(animation) {
            offsetY = 8.0
        }
    }

    private func runFadeInAnimation() {
        print("startView: フェードインアニメーションを実行します。")
        viewOpacity = 0.0
        isInteractable = false
        let animationDuration = 1.0

        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: animationDuration)) {
                viewOpacity = 1.0
            } completion: {
                isInteractable = true
                print("startViewのタップが可能になりました。")
            }
        }
    }
}
