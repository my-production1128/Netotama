//
//  MapView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/27.
//

import SwiftUI

// MARK: - Map View
struct MapView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var gameManager: GameManager
    @EnvironmentObject var musicplayer: SoundPlayer
    @State private var currentMode: GameMode
    
    init(path: Binding<NavigationPath>, mode: GameMode) {
        self._path = path
        self._currentMode = State(initialValue: mode)
        print("MapView init: mode=\(mode)")
    }
    
    private var currentTotalScore: Int {
        switch currentMode {
        case .happy:
            return gameManager.totalStars
        case .bad:
            return gameManager.totalThunders
        }
    }
    
    // 現在のモードに応じたステージ配列を取得
    private var currentStages: [Stage] {
        switch currentMode {
        case .happy:
            return gameManager.happyStages
        case .bad:
            return gameManager.badStages
        }
    }
    
    private let stagePositions: [CGPoint] = [
        CGPoint(x: 0.173, y: 0.68),  // Stage 1
        CGPoint(x: 0.28, y: 0.59),   // Stage 2
        CGPoint(x: 0.23, y: 0.47),   // Stage 3
        CGPoint(x: 0.38, y: 0.3),    // Stage 4
        CGPoint(x: 0.49, y: 0.18),   // Stage 5
        CGPoint(x: 0.63, y: 0.3),    // Stage 6
        CGPoint(x: 0.67, y: 0.56),   // Stage 7
        CGPoint(x: 0.87, y: 0.6),    // Stage 8
        CGPoint(x: 0.79, y: 0.74)    // Stage 9
    ]


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景切り替え
                Image(currentMode == .happy ? "Good_background" : "Bad_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // ステージボタンを配置
                ForEach(currentStages.indices, id: \.self) { index in
                    // 安全性チェック
                    if index < stagePositions.count {
                        let stage = currentStages[index]
                        let position = stagePositions[index]
                        
                        StageButton(stage: stage, mode: currentMode) {
                            musicplayer.playSE(fileName: "button_SE")
                            let unlocked = gameManager.handleStageTap(stage, path: &path, mode: currentMode)
                            
                            if !unlocked {
                                // 未解除ならフィードバック
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }
                        }
                        .position(
                            x: geometry.size.width * position.x,
                            y: geometry.size.height * position.y
                        )
                    }
                }
                
//                VStack{
//                    Button("リセット") {
//                        GameManager.shared.resetProgress()
//                    }
//                    .padding()
//                    .background(Color.red)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                    
//                    Button("デバック"){
//                        GameManager.shared.setDebugUnlockAll()
//                    }
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
                
                Image(currentMode == .happy ? "good_kumo_03" : "bad_kumo_02")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 600, height: 600)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.2) // 画面上部中央など
                Image(currentMode == .happy ? "good_kumo_03" : "bad_kumo_02")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500, height: 500)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.6) // 画面上部中央など
                
                // 戻るボタン
                VStack {
                    HStack {
                        Button {
                            musicplayer.playSE(fileName: "button_SE")
                            if !path.isEmpty{
                                path.removeLast()
                            }
                        } label: {
                            Image("back_iland")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
                
                // モード切り替えボタン
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            musicplayer.playSE(fileName: "button_SE")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMode = currentMode == .happy ? .bad : .happy
                            }
                        }) {
                            Image("turn_iland")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                        }
                    }
                    .padding()
                }
                .padding()
                
                //総数表示
                VStack {
                    HStack {
                        Spacer()
                        ScoreDisplayView(mode: currentMode, totalScore: currentTotalScore)
                    }
                    .padding(.top, 25)
                    Spacer()
                }
                .padding(75)
            }
            
        }
        .ignoresSafeArea()
        .onAppear {
            print("MapView appeared: currentMode=\(currentMode)")
            print("GameManager happyStages count: \(gameManager.happyStages.count)")
            print("GameManager badStages count: \(gameManager.badStages.count)")

            musicplayer.playBGM(fileName: "start_bgm")
        }
    }
}

// MARK: - Preview
#Preview {
    MapView(path: .constant(NavigationPath()), mode: .happy)
        .environmentObject(GameManager.shared)
}
