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

    var body: some View {
            Group {
                ZStack {
                    Image("step2_gauge_frame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)

//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: geometry.size.width)

                    Group {
                        Image("step2_yellow")
                            .resizable()
                            .scaledToFit()
                            .saturation(0)
                            .brightness(0.1)
                            .frame(width: width * 0.675, height: height * 0.25)
//                            .offset(x: 79,y: 26.5)

                        Image("step2_yellow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.675, height: height * 0.25)

//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geometry.size.width*0.675,height: geometry.size.height * 0.25)
//                            .offset(x: 79,y: 26.5)

                        Image("step2_gauge_sen")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.5, height: height * 0.25)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geometry.size.width * 0.23,height: geometry.size.height * 0.14)
//                            .offset(x: 84, y: 26.5)
                    }
                    .offset(x:22,y: 10)
                }
            }
//        }
    }
}

#Preview {
    Gauge(width: 300, height: 100)
}
