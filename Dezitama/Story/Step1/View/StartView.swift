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

    var body: some View {
        ZStack {
            // 背景
            Image("arasuzi_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            ZStack{

                // テキスト (WideRubyLabelRepresentable)
                if let dialogueText = dialogue.dialogueText {
                    WideRubyLabelRepresentable(
                        attributedText: dialogueText
                            .replacingOccurrences(of: "<br>", with: "\n")
                            .createWideRuby(font: UIFont.customFont(ofSize: 30), color: .black),
                        font: UIFont.customFont(ofSize: 30),
                        textColor: .black,
                        textAlignment: .center,
                        targetWidth: 700 // ★ 700から500に変更 (吹き出しに合わせる)
                    )
                    .frame(maxWidth: 750) // ★ 750から500に変更
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
                                .offset(y: offsetY) // アニメーション用offset
                                .onAppear {
                                    startLoopingAnimation() // アニメーション開始
                                }
                        }
                        .padding()
                        .offset(y: -90)
                    }
                }
            }
            .opacity(viewOpacity) // ZStack全体にフェードを適用

        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        // ★ 修正：.onAppear はアニメーション関数を呼ぶだけにします
        .onAppear {
            runFadeInAnimation()
        }
        // ★ 追加：dialogueTextが変更された時もアニメーション関数を呼びます
        .onChange(of: dialogue.dialogueText) {
            runFadeInAnimation()
        }
    }

    private func handleTap() {
        // 1. タップガード (storyline と同じ)
        guard isInteractable else {
            print("startViewアニメーション中のためタップを無視しました。")
            return
        }

        guard let nextSceneId = dialogue.nextSceneId else {
            print("startView: nextSceneId がありません。")
            return
        }

        // 2. "end" チェック (storyline と同じロジック)
        if nextSceneId.lowercased() == "end" {
            print("startView: 'end' を検出。親に通知します。")
            onNext("end")
            return
        }

        // 3. 次のシーンへ (storyline と同じロジック)
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

    // ★ 追加：フェードインアニメーションを共通関数化
    private func runFadeInAnimation() {
        print("startView: フェードインアニメーションを実行します。")
        viewOpacity = 0.0
        isInteractable = false
        let animationDuration = 1.0

        // 0.0で一度描画させてからアニメーションを開始するためのDispatchQueue
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: animationDuration)) {
                viewOpacity = 1.0
            } completion: {
                // アニメーション完了後にタップ可能にする
                isInteractable = true
                print("startViewのタップが可能になりました。")
            }
        }
    }
}
