//
//  GameManeger.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/09/21.
//

import Foundation
import SwiftUI

//ゲームモード
enum GameMode: String, Codable {
    case happy
    case bad
}

//ステージのデータ構造
struct Stage: Identifiable, Codable {
    let id: Int                 // ステージ番号（1..9）
    var score: Int              // 0..3（星/雷の数）
    var isUnlocked: Bool        // 解放フラグ
    var isPlayed: Bool          // 一度プレイしたか

    init(id: Int, score: Int = 0, isUnlocked: Bool = false, isPlayed: Bool = false) {
        self.id = id
        self.score = score
        self.isUnlocked = isUnlocked
        self.isPlayed = isPlayed
    }
}

/// 保存用コンテナ
private struct SaveContainer: Codable {
    var happyStages: [Stage]
    var badStages: [Stage]
    var isHappyUnlocked: Bool
}

final class GameManager: ObservableObject {
    static let shared = GameManager() // シングルトン

    // モードごとのステージ配列（Published -> View に反映）
    @Published var happyStages: [Stage] = []
    @Published var badStages: [Stage] = []

    // 特殊解放フラグなど
    @Published var isHappyUnlocked: Bool = false

    // 合計
    @Published private(set) var totalStars: Int = 0
    @Published private(set) var totalThunders: Int = 0

    // MARK: - Score Management Properties
    @Published var currentScore: Double = 0.0
    private var pointsPerChoice: Double = 0.0

    // UserDefaults key
    private let saveKey = "GameManager_v1_save"
    private let userDefaults = UserDefaults.standard

    private init() {
        loadProgress()
    }

    // MARK: - 初期化 / デフォルト生成
    private func defaultStages() -> [Stage] {
        (1...9).map { Stage(id: $0, score: 0, isUnlocked: $0 == 1, isPlayed: false) }
    }

    // MARK: - 保存 / 読み込み
    func loadProgress() {
        if let data = userDefaults.data(forKey: saveKey) {
            let decoder = JSONDecoder()
            if let container = try? decoder.decode(SaveContainer.self, from: data) {
                self.happyStages = container.happyStages
                self.badStages = container.badStages
                self.isHappyUnlocked = container.isHappyUnlocked
                recalcTotals()
                return
            } else {
                print("GameManager: load decode failed, using defaults")
            }
        }

        // 保存がなければデフォルト
        self.happyStages = defaultStages()
        self.badStages = defaultStages()
        self.isHappyUnlocked = false
        recalcTotals()
    }

    func saveProgress() {
        let container = SaveContainer(happyStages: happyStages, badStages: badStages, isHappyUnlocked: isHappyUnlocked)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(container) {
            userDefaults.set(data, forKey: saveKey)
        } else {
            print("GameManager: save encode failed")
        }
    }

    // MARK: - 集計
    private func recalcTotals() {
        totalStars = happyStages.reduce(0) { $0 + $1.score }
        totalThunders = badStages.reduce(0) { $0 + $1.score }
    }

    // MARK: - ヘルパー: インデックス取得
    private func index(of stageId: Int, in mode: GameMode) -> Int? {
        switch mode {
        case .happy:
            return happyStages.firstIndex { $0.id == stageId }
        case .bad:
            return badStages.firstIndex { $0.id == stageId }
        }
    }

    // MARK: - ステージ更新
    /// ステージのスコアを更新
    func updateStageScore(stageId: Int, mode: GameMode, earnedScore: Int) {
        let clamped = min(max(earnedScore, 0), 3)
        guard let idx = index(of: stageId, in: mode) else { return }
        print("✅ スコア更新: ステージ\(stageId) (\(mode)) に新しいハイスコア \(clamped) を保存します。")

        switch mode {
        case .happy:
            happyStages[idx].score = max(happyStages[idx].score, clamped)
        case .bad:
            badStages[idx].score = max(badStages[idx].score, clamped)
        }

        recalcTotals()
        saveProgress()
    }

    //ステージを「プレイ済み」にする
    func setStagePlayed(stageId: Int, mode: GameMode) {
        guard let idx = index(of: stageId, in: mode) else { return }
        switch mode {
        case .happy: happyStages[idx].isPlayed = true
        case .bad:   badStages[idx].isPlayed = true
        }
        saveProgress()
    }

    // 次のステージを解放（通常は前のステージをクリアしたときに呼ぶ）
    func unlockNextStage(after stageId: Int, mode: GameMode) {
        let nextId = stageId + 1
        guard nextId <= 9, let nextIdx = index(of: nextId, in: mode) else { return }
        switch mode {
        case .happy: happyStages[nextIdx].isUnlocked = true
        case .bad:   badStages[nextIdx].isUnlocked = true
        }
        saveProgress()
    }

    //ストーリー終了時に StoryView から呼ぶ総合処理
    //- これ1回で score 更新・isPlayed 設定・次ステージ解放・特殊解放判定・保存 まで行います
    func completeStage(stageId: Int, mode: GameMode, earnedScore: Int) {
        updateStageScore(stageId: stageId, mode: mode, earnedScore: earnedScore)
//        setStagePlayed(stageId: stageId, mode: mode)
        unlockNextStage(after: stageId, mode: mode)
        checkSpecialUnlocks(completedStage: stageId, mode: mode)
        recalcTotals()
        saveProgress()
    }

    // MARK: - 特殊解放のロジック（ここを増やしていく）
    //解放条件をここにまとめる
    func checkSpecialUnlocks(completedStage: Int, mode: GameMode) {
        // 「Badのステージ3が終了していて、雷が合計で5以上集まったら Happy を解放する」
//        if mode == .bad, completedStage == 3 {
//            if totalThunders >= 5 {
//                isHappyUnlocked = true
//            }
//        }

    }

    // MARK: - ハンドルタップ（ナビゲーション用）
    /// MapView 等からステージをタップしたときに呼ぶ
    @discardableResult
    func handleStageTap(_ stage: Stage, path: inout NavigationPath, mode: GameMode) -> Bool {
        return handleStageTap(stageId: stage.id, path: &path, mode: mode)
    }

    @discardableResult
    func handleStageTap(stageId: Int, path: inout NavigationPath, mode: GameMode) -> Bool {
        guard let idx = index(of: stageId, in: mode) else { return false }
        let actualStage = (mode == .happy) ? happyStages[idx] : badStages[idx]
        guard actualStage.isUnlocked else {
            print("Stage \(stageId) is locked")
            return false
        }

        // 遷移先をここに書く
        switch mode {
        case .bad:
            switch stageId {
            case 1:
                path.append(ViewBuilderPath.StoryProgressView(stageIndex: 0))
            case 2:
                path.append(ViewBuilderPath.GroupchatView)
            case 3:
                path.append(ViewBuilderPath.kakusanView)
            case 4:
                // path.append(ViewBuilderPath.BadStage4View)
                break
            case 5:
                // path.append(ViewBuilderPath.BadStage5View)
                break
            case 6:
                // path.append(ViewBuilderPath.BadStage6View)
                break
            case 7:
                // path.append(ViewBuilderPath.BadStage7View)
                break
            case 8:
                // path.append(ViewBuilderPath.BadStage8View)
                break
            case 9:
                // path.append(ViewBuilderPath.BadStage9View)
                break
            default:
                print("Unhandled Bad stage: \(stageId)")
            }
        case .happy:
            switch stageId {
            case 1:
                path.append(ViewBuilderPath.GoodStoryBranchView("good_netomo_story1", stageId, .happy))
            case 2:
                path.append(ViewBuilderPath.GoodStoryBranchView("good_netomo_story2", stageId, .happy))
            case 3:
                path.append(ViewBuilderPath.GoodStoryBranchView("good_netomo_story3", stageId, .happy))
            case 4:
                path.append(ViewBuilderPath.GoodStoryBranchView("good_gurucha_story1", stageId, .happy))
                break
            case 5:
                path.append(ViewBuilderPath.GoodStoryBranchView("good_gurucha_story2", stageId, .happy))
                break
            case 6:
                path.append(ViewBuilderPath.GoodStoryBranchView("good_gurucha_story3", stageId, .happy))
                break
            case 7:
                // path.append(ViewBuilderPath.HappyStage7View)
                break
            case 8:
                // path.append(ViewBuilderPath.HappyStage8View)
                break
            case 9:
                // path.append(ViewBuilderPath.HappyStage9View)
                break
            default:
                print("Unhandled Happy stage: \(stageId)")
            }
        }

        return true
    }

    // MARK: - Score to Stars Conversion
        /// 現在のスコア（0-100）を星の数（0-3）に変換する
        func scoreToStars(score: Double) -> Int {
            if score > 80 {
                return 3 // 80点より大きい場合は星3
            } else if score > 40 {
                return 2 // 40点より大きい場合は星2
            } else if score > 0 {
                return 1 // 0点より大きい場合は星1
            } else {
                return 0 // 0点の場合は星0
            }
        }
    
    // MARK: - デバッグ / リセット
    // 全解放／満点にする
    func setDebugUnlockAll() {
        for i in happyStages.indices {
            happyStages[i].isUnlocked = true
            happyStages[i].score = 0
            happyStages[i].isPlayed = true
        }
        for i in badStages.indices {
            badStages[i].isUnlocked = true
            badStages[i].score = 0
            badStages[i].isPlayed = true
        }
        isHappyUnlocked = true
        recalcTotals()
        saveProgress()
    }

    /// 進行リセット（初期状態に戻す）
    func resetProgress() {
        happyStages = defaultStages()
        badStages = defaultStages()
        isHappyUnlocked = false
        recalcTotals()
        saveProgress()
    }

    // MARK: - Score Management Methods
    /// ストーリー開始時にスコアを初期化し、分岐ごとの基本ポイントを計算する
    func startStory(storyId: String, allBranchings: [Branching]) {
        // スコアをリセット
        currentScore = 0.0

        // このストーリーIDに含まれる選択肢の数を数える
        let choiceCount = allBranchings.filter { $0.storyId == storyId && $0.isChoice == true }.count

        // 選択肢が1つ以上あれば、1回あたりの基本ポイントを計算
        if choiceCount > 0 {
            pointsPerChoice = 100.0 / Double(choiceCount)
        } else {
            pointsPerChoice = 0.0
        }
        print("ストーリー開始: \(storyId), 1分岐あたりの基本ポイント: \(pointsPerChoice)")
        print("--- スコア計算開始 ---")
        print("ストーリーID: \(storyId)")
        print("選択肢の数: \(choiceCount) 問")
        print("1問あたりの基本点: \(pointsPerChoice) 点")
        print("--------------------")
    }

    /// 選択肢のパーセンテージに応じてスコアを加算する
    // GameManeger.swift の中
        func addScore(percentage: Double?) {
            guard let percentage = percentage else {
                print("スコア加算エラー: パーセンテージがnilのため加算できませんでした。")
                return
            }

            let scoreToAdd = pointsPerChoice * percentage
            currentScore += scoreToAdd

            // スコアが0から100の範囲に収まるように調整
            currentScore = min(max(currentScore, 0.0), 100.0)

            // ▼▼▼ ここから調査用プリント ▼▼▼
            print("--- スコア加算 ---")
            print("加算されるスコア: \(scoreToAdd) 点")
            print("現在の合計スコア: \(currentScore) 点")
            print("--------------------")
        }
}
