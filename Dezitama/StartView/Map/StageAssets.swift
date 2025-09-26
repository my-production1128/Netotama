//
//  StageAssets.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/09/26.
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
        // ▼▼▼ このブロックをまるごと置き換え ▼▼▼
        var imageName = "" // 表示する画像名を入れる変数
        if !stage.isUnlocked {
            imageName = "botann_unlocked_\(stage.id)"
        } else {
            let clampedScore = min(max(stage.score, 0), 3)
            switch mode {
            case .happy:
                imageName = "botann\(stage.id)_star\(clampedScore)"
            case .bad:
                imageName = "botann\(stage.id)_thunder\(clampedScore)"
            }
        }
        // print文で、どの画像を表示しようとしているか確認
        print("▶️ ステージ\(stage.id)に表示しようとしている画像名: \(imageName)")
        return imageName
    }
}

// MARK: - Total Score
struct ScoreDisplayView: View {
    let mode: GameMode
    let totalScore: Int
    private let maxScore = 27

    var body: some View {
        Text(displayText)
            .font(Font(UIFont.customFont(ofSize: 43)))
            .foregroundColor(.black)
    }

    // 表示テキスト
    private var displayText: String {
        switch mode {
        case .happy:
            return "\(totalScore)/\(maxScore)"
        case .bad:
            return "\(totalScore)/\(maxScore)"
        }
    }
}


// MARK: - Kumo
struct KumoView: View {
    var body: some View {
        Image("kumo")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
    }
}


