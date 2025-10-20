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
    @Binding var currentMode: GameMode

    init(width: CGFloat, height: CGFloat, score: Double, currentMode: Binding<GameMode>) {
        self.width = width
        self.height = height
        self.score = score
        self._currentMode = currentMode
        self._animatedProgress = State(initialValue: score / 100.0)
    }


    var body: some View {

        let progress = score / 100.0

        ZStack {
            Image(currentMode == .happy ? "step2_gauge_frame" : "step1_gauge_frame")
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

                Image(currentMode == .happy ? "step2_yellow" :"step1_green")
                    .resizable()
                    .frame(width: width * 0.59, height: height * 0.25)
                    .mask(
                        HStack {
                            Rectangle()
                                .frame(width: width * 0.59 * CGFloat(animatedProgress))
                            Spacer(minLength: 0)
                        }
                    )

                Image("step2_gauge_sen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.5, height: height * 0.25)
            }
            .offset(x:22,y: 7)
        }
        .scaleEffect(scale, anchor: .topTrailing)
        .onChange(of: score) {
            guard progress > 0 else {
                if animatedProgress != 0.0 {
                    animatedProgress = 0.0
                }
                return
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                scale = 1.2
            }completion: {
                withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) {
                animatedProgress = progress
                } completion: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
            }
        }
    }
}
