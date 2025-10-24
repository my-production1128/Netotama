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
    
    @State private var showStageSheet = false
    @State private var selectedStage: Stage?
    @State private var showTutorial = false  // チュートリアル表示用
    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    private var currentTotalScore: Int {
        switch gameManager.currentMode {
        case .happy:
            return gameManager.totalStars
        case .bad:
            return gameManager.totalThunders
        }
    }
    
    // 現在のモードに応じたステージ配列を取得
    private var currentStages: [Stage] {
        switch gameManager.currentMode {
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
        switch gameManager.currentMode {
        case .happy:
            return happyStagePositions
        case .bad:
            return badStagePositions
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // メインコンテンツ
                ZStack {
                    // currentMode ごとに別Viewとして扱う
                    if gameManager.currentMode == .happy {
                        modeGroupView(geometry: geometry, mode: .happy)
                            .transition(
                                .opacity
                                    .animation(.easeInOut(duration: 0.6))
                            )
                            .id(gameManager.currentMode)
                    } else {
                        modeGroupView(geometry: geometry, mode: .bad)
                            .transition(
                                .opacity
                                    .animation(.easeInOut(duration: 0.6))
                            )
                            .id(gameManager.currentMode)
                    }
                    //デバックボタン
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
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    gameManager.currentMode = gameManager.currentMode == .happy ? .bad : .happy
                                }
                            }) {
                                Image("stage_turn")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 100)
                            }
                            .padding(10)
                        }
                        .padding(10)
                    }
                    .padding(10)

                    //シート
                    if showStageSheet, let stage = selectedStage {
                        ZStack {
                            // 背景（タップで閉じる）
                            Color.white.opacity(0.6)
                                .ignoresSafeArea()
                                .contentShape(Rectangle()) // ← タップ判定を明確に
                                .onTapGesture {
                                    musicplayer.playSE(fileName: "button_SE")
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showStageSheet = false
                                        selectedStage = nil
                                    }
                                }

                            // 前面のシート（StageIntroOverlay）
                            StageIntroOverlay(
                                stage: stage,
                                mode: gameManager.currentMode,
                                onClose: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showStageSheet = false
                                        selectedStage = nil
                                    }
                                },
                                onStart: {
                                    showStageSheet = false
                                    _ = gameManager.handleStageTap(stage, path: &path, mode: gameManager.currentMode)
                                    selectedStage = nil
                                }
                            )
                            .environmentObject(musicplayer)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .opacity(showTutorial ? 0 : 1) // チュートリアル表示中は非表示
                
                // チュートリアルを全画面表示（完全に独立）
                if showTutorial {
                    MapTutorialView(isPresented: $showTutorial)
                        .transition(.opacity)
                        .zIndex(999) // 最前面に表示
                        .ignoresSafeArea()
                }
            }
            .animation(.easeInOut(duration: 0.8), value: gameManager.currentMode)
        }
        .ignoresSafeArea()
        .onAppear {
            print("MapView appeared: currentMode=\(gameManager.currentMode)")
            print("GameManager happyStages count: \(gameManager.happyStages.count)")
            print("GameManager badStages count: \(gameManager.badStages.count)")
            musicplayer.playBGM(fileName: "start_bgm")
            
            // Choiceのチュートリアルを見終わって、かつMapのチュートリアルを見ていない場合に表示
            if TutorialManager.shared.hasSeenTutorial(for: "choice") &&
                !TutorialManager.shared.hasSeenTutorial(for: "map") {
                showTutorial = true
            }
        }
    }
    
    // 各ステージIDごとに雲の座標の関数
    // 各雲の表示位置をステージごとに指定
    private func cloudPosition(for stageId: Int, in geometry: GeometryProxy, mode: GameMode) -> CGPoint? {
        switch mode {
        case .bad:
            switch stageId {
            case 4:
                return CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.65)
            case 7:
                return CGPoint(x: geometry.size.width * 0.76, y: geometry.size.height * 0.54)
            default:
                return nil
            }
            
        case .happy:
            switch stageId {
            case 1:
                return CGPoint(x: geometry.size.width * 0.23, y: geometry.size.height * 0.6)
            case 4:
                return CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.24)
            case 7:
                return CGPoint(x: geometry.size.width * 0.77, y: geometry.size.height * 0.65)
            default:
                return nil
            }
        }
    }
    
    
    @ViewBuilder
    private func modeGroupView(geometry: GeometryProxy, mode: GameMode) -> some View {
        Group {
            // 背景
            Image(mode == .happy ? "Good_background" : "Bad_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // ステージボタン
            ForEach(currentStages(for: mode).indices, id: \.self) { index in
                if index < stagePositions(for: mode).count {
                    let stage = currentStages(for: mode)[index]
                    let position = stagePositions(for: mode)[index]
                    
                    StageButton(stage: stage, mode: mode) {
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
            
            // CloudView
            ForEach(currentStages(for: mode)) { stage in
                if let cloudName = gameManager.cloudImageName(for: stage.id, mode: mode),
                   let cloudPosition = cloudPosition(for: stage.id, in: geometry, mode: mode) {
                    CloudView(
                        id: stage.id,
                        imageName: cloudName,
                        position: cloudPosition,
                        geometry: geometry,
                        mode: mode
                    )
                }
            }
            
            // スコア表示
            VStack {
                HStack {
                    Spacer()
                    ScoreDisplayView(mode: mode, totalScore: totalScore(for: mode))
                }
                .padding(.top, 20)
                Spacer()
            }
            .padding(75)
        }
    }
    
    private func currentStages(for mode: GameMode) -> [Stage] {
        switch mode {
        case .happy: return gameManager.happyStages
        case .bad: return gameManager.badStages
        }
    }

    private func stagePositions(for mode: GameMode) -> [CGPoint] {
        switch mode {
        case .happy: return happyStagePositions
        case .bad: return badStagePositions
        }
    }

    private func totalScore(for mode: GameMode) -> Int {
        switch mode {
        case .happy: return gameManager.totalStars
        case .bad: return gameManager.totalThunders
        }
    }
}
