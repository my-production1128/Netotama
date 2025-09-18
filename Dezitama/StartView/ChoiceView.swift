//
//  ChoiceView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/27.
//

import SwiftUI

struct ChoiceView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Button {
                        path.append(ViewBuilderPath.MapViewBad)
                    } label: {
                        Image("Bad_Button")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.4)
                            .position(
                                x: geometry.size.width * 0.5,
                                y: geometry.size.height * 0.3
                            )
                    }
                    
                    // Happy ボタン（Bad Stage3クリア後に解放）
                    Button {
//                        if gameManager.isHappyUnlocked {
                            path.append(ViewBuilderPath.MapViewHappy)
//                        }
                    } label: {
                        Image("Good_Button")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.45)
                            .position(
                                x: geometry.size.width * 0.5,
                                y: geometry.size.height * 0.2
                            )
//                            .grayscale(gameManager.isHappyUnlocked ? 0 : 0.9) // ロック時グレー
//                            .opacity(gameManager.isHappyUnlocked ? 1.0 : 0.5) // 半透明
                    }
                    .disabled(!gameManager.isHappyUnlocked)
                }
            }
        }
    }
}
