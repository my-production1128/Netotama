import SwiftUI

// MARK: - Game Mode
enum GameMode {
    case happy
    case bad
}

// MARK: - Data Models
struct Stage: Identifiable {
    let id = UUID()
    let number: Int
    var score: Int
    var isUnlocked: Bool
}

// MARK: - Game Logic
class GameManager: ObservableObject {
    @Published var stages: [Stage] = []
    
    //これデバックでtrueにしてる
    @Published var isHappyUnlocked: Bool = true
    
    init() {
        initializeStages()
    }
    
    private func initializeStages() {
        stages = Array(1...9).map { stageNumber in
            Stage(
                number: stageNumber,
                score: 0,
                isUnlocked: stageNumber == 1
            )
        }
    }
    
    func unlockNextStage(completedStageNumber: Int, earnedScore: Int, mode: GameMode) {
        // 現在のステージ更新
        if let index = stages.firstIndex(where: { $0.number == completedStageNumber }) {
            stages[index].score = max(stages[index].score, earnedScore)
        }
        
        // 次のステージ解放
        let nextStageNumber = completedStageNumber + 1
        if nextStageNumber <= 9,
           let nextIndex = stages.firstIndex(where: { $0.number == nextStageNumber }) {
            stages[nextIndex].isUnlocked = true
        }
        
        // ここもデバック用だからあとでコメントアウト外す
//        if mode == .bad && completedStageNumber == 3 {
//            isHappyUnlocked = true
//        }
    }
    
    func handleStageTap(_ stage: Stage, path: inout NavigationPath, mode: GameMode) {
        if stage.isUnlocked {
            print("Stage \(stage.number) selected in \(mode) mode")
            
            switch mode {
            case .bad:
                switch stage.number {
                case 1:
                    path.append(ViewBuilderPath.GroupchatView)
//                case 2:
//
//                case 3:
//
                default:
                    break
                }
              
                
            //ここに書いてね！遷移先
            case .happy:
                switch stage.number {
                case 1:
                    path.append(ViewBuilderPath.GoodStoryBranchView("good_netomo_story1"))
//                case 2:
//                    path.append(ViewBuilderPath.HappyStage2View)
                default:
                    break
                }
            }
            
        } else {
            print("Stage \(stage.number) is locked")
            // ロック中のときはフィードバック
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }

}

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
        .grayscale(stage.isUnlocked ? 0 : 0.8)
    }
    
    private var buttonImageName: String {
        switch mode {
        case .happy:
            return "botann\(stage.number)_star\(stage.score)"
        case .bad:
            return "botann\(stage.number)_thunder\(stage.score)"
        }
    }
}

// MARK: - Map View
struct MapView: View {
    @Binding var path: NavigationPath
    @StateObject private var gameManager = GameManager()
    let mode: GameMode
    
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
                Image(mode == .happy ? "Good_background" : "Bad_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // ステージボタンを配置
                ForEach(gameManager.stages.indices, id: \.self) { index in
                    let stage = gameManager.stages[index]
                    let position = stagePositions[index]
                    
                    StageButton(stage: stage, mode: mode) {
                        gameManager.handleStageTap(stage, path: &path, mode: mode)
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

// MARK: - Preview
#Preview {
    NavigationStack {
        MapView(path: .constant(NavigationPath()), mode: .happy)
    }
}
