//
//  gauge.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/09/16.
//

import SwiftUI

struct Gauge: View {
    var width: CGFloat
        var height: CGFloat
        var score: Double

        @State private var scale: CGFloat = 1.0
        @State private var animatedProgress: Double
        @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var musicplayer: SoundPlayer

        // initから currentMode を削除
        init(width: CGFloat, height: CGFloat, score: Double) {
            self.width = width
            self.height = height
            self.score = score
            self._animatedProgress = State(initialValue: score / 100.0)
        }



    var body: some View {

        let progress = score / 100.0

        ZStack {
            Image(gameManager.currentMode == .happy ? "step2_gauge_frame" : "step1_gauge_frame")
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)

            Group {
                //                        バーの背景（灰色）
                Image("step2_yellow")
                    .resizable()
                    .saturation(0)
                    .brightness(0.1)
                    .frame(width: width * 0.59, height: height * 0.25)

                Image(gameManager.currentMode == .happy ? "step2_yellow" :"step1_green")
                    .resizable()
                    .frame(width: width * 0.59, height: height * 0.25)
                    .mask(
                        HStack {
                            Rectangle()
                                .frame(width: width * 0.59 * CGFloat(animatedProgress))
                            Spacer(minLength: 0)
                        }
                    )

//                Image("step2_gauge_sen")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: width * 0.5, height: height * 0.25)
            }
            .offset(x:22,y: 7)
        }
        .scaleEffect(scale, anchor: .topTrailing)
        .onChange(of: score) { oldValue, newValue in // ← oldValue, newValue を受け取る
                let progress = newValue / 100.0

                // ▼▼▼ ログ追加 ▼▼▼
                print("--- Gauge onChange ---")
                print("Score changed from \(oldValue) to \(newValue)")
//                print("Current lastChoicePercentage: \(gameManager.lastChoicePercentage)")

                guard progress > 0 || newValue > 0 else {
                    if animatedProgress != 0.0 {
                        animatedProgress = 0.0
                    }
                    print("Guard failed: progress <= 0") // ▼▼▼ ログ追加 ▼▼▼
                    return
                }

                // --- アニメーション 1 (拡大) ---
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    scale = 1.2
                } completion: {
                    print("Completion 1: Scale animation finished.") // ▼▼▼ ログ追加 ▼▼▼

                    // --- 効果音再生 ---
                    if let percentage = gameManager.lastChoicePercentage {
                         print("Percentage found: \(percentage)") // ▼▼▼ ログ追加 ▼▼▼
                        if abs(percentage - 1.0) < 0.01 {
                            print("Playing gauge_1.0_SE") // ▼▼▼ ログ追加 ▼▼▼
                            musicplayer.playSE(fileName: "gauge_1.0_SE")
                        } else if abs(percentage - 0.3) < 0.01 {
                            print("Playing gauge_0.3_SE") // ▼▼▼ ログ追加 ▼▼▼
                            musicplayer.playSE(fileName: "gauge_0.3_SE")
                        } else {
                            print("Percentage is not 1.0 or 0.3, playing gauge_fill_SE") // ▼▼▼ ログ追加 ▼▼▼
                            musicplayer.playSE(fileName: "gauge_fill_SE") // 条件外の場合も汎用音を鳴らす
                        }

                        // percentage を nil に戻す
                        DispatchQueue.main.async {
                            print("Resetting lastChoicePercentage to nil") // ▼▼▼ ログ追加 ▼▼▼
                            gameManager.lastChoicePercentage = nil
                        }
                    } else {
                        // percentage が nil だった場合も汎用音を鳴らす
                         print("Percentage is nil, playing gauge_fill_SE") // ▼▼▼ ログ追加 ▼▼▼
                         musicplayer.playSE(fileName: "gauge_fill_SE")
                    }

                    // --- アニメーション 2 (バー伸長) ---
                    withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) {
                        animatedProgress = progress
                    } completion: {
                         print("Completion 2: Progress animation finished.") // ▼▼▼ ログ追加 ▼▼▼
                        // --- アニメーション 3 (縮小) ---
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            scale = 1.0
                        }
                    }
                }
            }
    }
}
