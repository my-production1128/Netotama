//
//  MapView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/27.
//

import SwiftUI

// MARK: - Stage Button
struct StageButton: View {
    let stage: Stage
    let mode: GameMode
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(buttonImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 120)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var buttonImageName: String {
        // 未解除の時
        if !stage.isUnlocked {
            return "botann_unlocked_\(stage.id)"
        }
        
        let clampedScore = min(max(stage.score, 0), 3)
        switch mode {
        case .happy:
            return "botann\(stage.id)_star\(clampedScore)"
        case .bad:
            return "botann\(stage.id)_thunder\(clampedScore)"
        }
    }
}

// MARK: - Map View
struct MapView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var gameManager: GameManager
    @State private var currentMode: GameMode
    
    init(path: Binding<NavigationPath>, mode: GameMode) {
        self._path = path
        self._currentMode = State(initialValue: mode)
        print("MapView init: mode=\(mode)")  // ← これがログに出ていない
    }
    
//    private var currentTotalScore: Int {
//        switch currentMode {
//        case .happy:
//            return gameManager.totalStars
//        case .bad:
//            return gameManager.totalThunders
//        }
//    }
//    
    
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
                
                // 戻るボタン
                VStack {
                    HStack {
                        Button {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        } label: {
                            Image("back_iland")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                        }
                        Spacer()
                        
//                        ScoreDisplayView(mode: currentMode, totalScore: currentTotalScore)
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
            }
        }
        .ignoresSafeArea()
        .onAppear {
            print("MapView appeared: currentMode=\(currentMode)")
            print("GameManager happyStages count: \(gameManager.happyStages.count)")
            print("GameManager badStages count: \(gameManager.badStages.count)")
        }
    }
}

// MARK: - Preview
#Preview {
    MapView(path: .constant(NavigationPath()), mode: .happy)
        .environmentObject(GameManager.shared)
}
