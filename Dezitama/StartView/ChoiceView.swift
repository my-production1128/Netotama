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
    @EnvironmentObject var musicplayer: SoundPlayer
    
    @State private var isMenuVisible: Bool = false // メニュー開閉制御

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Image("choice_background")
                    .resizable()
                    .ignoresSafeArea()
                    // メニュー開いてる時はタップで閉じる
                    .onTapGesture {
                        if isMenuVisible {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isMenuVisible = false
                            }
                        }
                    }

                // メインボタン
                VStack {
                    Button {
                        musicplayer.playSE(fileName: "button_SE")
                        path.append(ViewBuilderPath.MapViewBad)
                    } label: {
                        Image("Bad_Button")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.4)
                            .offset(y: -10)
                    }
                    
                    Button {
                        musicplayer.playSE(fileName: "button_SE")
                        path.append(ViewBuilderPath.MapViewHappy)
                    } label: {
                        Image("Good_Button")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.4)
                            .offset(y: -10)
                    }
                }

                // 右上のinfoボタン
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isMenuVisible.toggle()
                                musicplayer.playSE(fileName: "button_SE")
                            }
                        } label: {
                            Image("imark")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        .padding(20)
                    }
                    Spacer()
                }

                // MenuView の統合（あなたのオリジナル版）
                MenuView(isOpen: $isMenuVisible, path: $path)
                    .zIndex(2) // 最前面に表示
            }
        }
        .onAppear {
            musicplayer.playBGM(fileName: "start_bgm")
        }
    }
}
