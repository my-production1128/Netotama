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
    @State private var showTutorial = false
    
    @State private var isMenuVisible: Bool = false // メニュー開閉制御
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // メインコンテンツ
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
                            gameManager.currentMode = .bad
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
                            gameManager.currentMode = .happy
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
                    
                    // MenuView の統合
                    MenuView(isOpen: $isMenuVisible, path: $path)
                        .zIndex(2)
                }
                .opacity(showTutorial ? 0 : 1) // チュートリアル表示中は非表示
                
                // チュートリアルを全画面表示（完全に独立）
                if showTutorial {
                    ChoiceTutorialView(isPresented: $showTutorial)
                        .transition(.opacity)
                        .zIndex(999) // 最前面に表示
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            musicplayer.playBGM(fileName: "island_bgm")
            
            // 初回表示時のみチュートリアルを表示
            if !TutorialManager.shared.hasSeenTutorial(for: "choice") {
                        showTutorial = true
            }
        }
    }
}
