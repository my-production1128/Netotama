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
        let formattedScore = String(format: "%02d", totalScore)

        switch mode {
        case .happy:
            return "\(formattedScore)/\(maxScore)"
        case .bad:
            return "\(formattedScore)/\(maxScore)"
        }
    }
}

struct StageIntroOverlay: View {
    let stage: Stage
    let mode: GameMode
    let onClose: () -> Void
    let onStart: () -> Void
    
    @EnvironmentObject var musicplayer: SoundPlayer
    
    var body: some View {
        GeometryReader { geometry in
            Image(sheetImageName)
                .resizable()
                .scaledToFit()
                .frame(
                    width: geometry.size.width * 0.5)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .overlay(alignment: .bottomTrailing) {
                        Button(action: {
                            musicplayer.playSE(fileName: "button_SE")
                            onStart()
                        }) {
                            Image("sheet_start")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.15)
                        }
                        .padding(.trailing, geometry.size.width * 0.31)
                        .padding(.bottom, geometry.size.height * 0.18)
                    }
        }
    }
    
    private var sheetImageName: String {
        let imageName: String
        switch mode {
        case .bad:
            imageName = "sheet_bad\(stage.id)"
        case .happy:
            imageName = "sheet_good\(stage.id)"
        }
        return imageName
    }
}
