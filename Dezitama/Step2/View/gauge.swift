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

    @Binding var currentMode: GameMode


    var body: some View {

        let progress = score / 100.0

            Group {
                ZStack {
//                    Image("step2_gauge_frame")
                    Image(currentMode == .happy ? "step2_gauge_frame" : "step1_gauge_frame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)

                    Group {
//                        バーの背景（灰色）
                        Image("step2_yellow")
                            .resizable()
                            .scaledToFit()
                            .saturation(0)
                            .brightness(0.1)
                            .frame(width: width * 0.675, height: height * 0.25)

                        Image(currentMode == .happy ? "step2_yellow" :"step1_green")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.675, height: height * 0.25)
                            .mask(
                                // ゲージの幅に合わせて、左から progress の割合だけ表示する
                                GeometryReader { geometry in
                                    HStack {
                                        Rectangle()
                                            .frame(width: geometry.size.width * CGFloat(progress))
                                            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.6), value: progress)
                                        Spacer(minLength: 0)
                                    }
                                }
                            )

                        Image("step2_gauge_sen")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.5, height: height * 0.25)
                    }
                    .offset(x:22,y: 7)
                }
            }
//        }
    }
}
