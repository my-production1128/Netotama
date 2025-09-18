//
//  MapView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/27.
//
import SwiftUI

// MARK: - Data Models
struct Stage: Identifiable {
    let id = UUID()
    let number: Int
    var thunders: Int
    var isUnlocked: Bool
}

// MARK: - Game Logic
class GameManager: ObservableObject {
    @Published var stages: [Stage] = []
    
    init() {
        initializeStages()
    }
    
    private func initializeStages() {
        stages = Array(1...9).map { stageNumber in
            Stage(
                number: stageNumber,
                thunders: 0, // 初回使用時は全て0
                isUnlocked: stageNumber == 1 // Stage 1のみ最初から解放
            )
        }
    }
    
    func unlockNextStage(completedStageNumber: Int, earnedThunders: Int) {
        // 現在のステージの雷を更新
        if let index = stages.firstIndex(where: { $0.number == completedStageNumber }) {
            stages[index].thunders = max(stages[index].thunders, earnedThunders)
        }
        
        // 次のステージを解放
        let nextStageNumber = completedStageNumber + 1
        if nextStageNumber <= 9,
           let nextIndex = stages.firstIndex(where: { $0.number == nextStageNumber }) {
            stages[nextIndex].isUnlocked = true
        }
    }
    
    func handleStageTap(_ stage: Stage) {
        if stage.isUnlocked {
            print("Stage \(stage.number) selected")
            // ここでゲーム画面への遷移
        } else {
            print("Stage \(stage.number) is locked")
            // ロックされたステージのフィードバック（振動など）
        }
    }
}

// MARK: - Stage Button
struct StageButton: View {
    let stage: Stage
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image("botann\(stage.number)_thunder\(stage.thunders)")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 120)
        }
        .buttonStyle(PlainButtonStyle())
        .grayscale(stage.isUnlocked ? 0 : 0.8)
    }
}

// MARK: - Main Map View
struct MapView: View {
    @Binding var path: NavigationPath
    @StateObject private var gameManager = GameManager()
    
    // ステージの位置を直接定義（シンプル）
    private let stagePositions: [CGPoint] = [
        CGPoint(x: 0.173, y: 0.68),  // Stage 1
        CGPoint(x: 0.28, y: 0.59),   // Stage 2
        CGPoint(x: 0.23, y: 0.47),   // Stage 3
        CGPoint(x: 0.38, y: 0.3),  // Stage 4
        CGPoint(x: 0.49, y: 0.18),   // Stage 5
        CGPoint(x: 0.63, y: 0.3),  // Stage 6
        CGPoint(x: 0.67, y: 0.56),  // Stage 7
        CGPoint(x: 0.87, y: 0.6),   // Stage 8
        CGPoint(x: 0.79, y: 0.74)   // Stage 9
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景画像
                Image("Bad_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // ステージボタンを配置
                ForEach(Array(gameManager.stages.enumerated()), id: \.element.id) { index, stage in
                    let position = stagePositions[index]
                    
                    StageButton(stage: stage) {
                        gameManager.handleStageTap(stage)
                    }
                    .position(
                        x: geometry.size.width * position.x,
                        y: geometry.size.height * position.y
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MapView(path: .constant(NavigationPath()))
}
