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
    @Binding var currentMode: GameMode
    
    @State private var showStageSheet = false
    @State private var selectedStage: Stage?
    
    init(path: Binding<NavigationPath>, mode: GameMode, currentMode: Binding<GameMode>) {
        self._path = path
        self._currentMode = currentMode
        self._currentMode.wrappedValue = mode
        
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
    
    // Happy モード用の位置
    private let happyStagePositions: [CGPoint] = [
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
    
    // Bad モード用の位置
    private let badStagePositions: [CGPoint] = [
        CGPoint(x: 0.25, y: 0.098),     // Stage 1
        CGPoint(x: 0.38, y: 0.18),    // Stage 2
        CGPoint(x: 0.25, y: 0.3),    // Stage 3
        CGPoint(x: 0.22, y: 0.59),   // Stage 4
        CGPoint(x: 0.33, y: 0.7),    // Stage 5
        CGPoint(x: 0.45, y: 0.6),    // Stage 6
        CGPoint(x: 0.68, y: 0.46),    // Stage 7
        CGPoint(x: 0.87, y: 0.48),   // Stage 8
        CGPoint(x: 0.8, y: 0.63)    // Stage 9
    ]
    
    // 現在のモードに応じた位置配列を取得
    private var currentStagePositions: [CGPoint] {
        switch currentMode {
        case .happy:
            return happyStagePositions
        case .bad:
            return badStagePositions
        }
    }
    
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
                    if index < currentStagePositions.count {
                        let stage = currentStages[index]
                        let position = currentStagePositions[index]
                        
                        StageButton(stage: stage, mode: currentMode) {
                            musicplayer.playSE(fileName: "button_SE")
                            if stage.isUnlocked {
                                selectedStage = stage
                                showStageSheet = true
                            } else {
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
                
                VStack{
                    Button("リセット") {
                        GameManager.shared.resetProgress()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("デバック"){
                        GameManager.shared.setDebugUnlockAll()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
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
                        .padding(5)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(5)
                
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
                        .padding(8)
                    }
                    .padding(8)
                }
                .padding(8)
                
                
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
                if showStageSheet, let stage = selectedStage {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // 背景タップでステージに遷移
                            musicplayer.playSE(fileName: "button_SE")
                            showStageSheet = false
                            _ = gameManager.handleStageTap(stage, path: &path, mode: currentMode)
                            selectedStage = nil
                        }
                    
                    StageIntroOverlay(
                        stage: stage,
                        mode: currentMode,
                        onClose: {
                            showStageSheet = false
                            selectedStage = nil
                        },
                        onStart: {
                            showStageSheet = false
                            _ = gameManager.handleStageTap(stage, path: &path, mode: currentMode)
                            selectedStage = nil
                        }
                    )
                    .environmentObject(musicplayer)
                    .transition(.scale.combined(with: .opacity))
                }
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
