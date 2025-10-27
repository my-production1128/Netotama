//
//  ScreenSceneView.swift (StoryBranchView.swiftファイル内に追加)
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/27.
//

import SwiftUI

struct ScreenSceneView: View {

    // MARK: - Properties

    // 親Viewからのデータ
    let current: Branching
    let geometry: GeometryProxy
    let talkFont: UIFont
    let branchingMap: [String: Branching]

    // 親Viewと同期するState
    @Binding var currentSceneId: String
    @Binding var currentChoiceScene: Branching?
    @Binding var isPopupVisible: Bool
    @Binding var conversationHistory: [Branching]
    @Binding var screenTextOffset: CGFloat

    // EnvironmentObject
    @EnvironmentObject var musicplayer: SoundPlayer

    // MARK: - Body

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 100)

            WideRubyLabelRepresentable(
                attributedText: (current.text)
                    .replacingOccurrences(of: "<br>", with: "\n")
                    .createWideRuby(font: UIFont.customFont(ofSize: 45), color: .black),
                font: talkFont,
                textColor: .black,
                textAlignment: .center,
                targetWidth: 700
            )
                .font(.custom("MPLUS1-Regular", size: 45))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .offset(x: screenTextOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .contentShape(Rectangle())
        .onAppear {
            musicplayer.playBGM(fileName: current.bgm)

            let totalDuration: TimeInterval = 3.6
            let moveInDuration: TimeInterval = 0.8
            let waitDuration: TimeInterval = 2.0
            let moveOutDuration: TimeInterval = totalDuration - moveInDuration - waitDuration
            let startOffset = -geometry.size.width
            screenTextOffset = startOffset

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: moveInDuration)) {
                    screenTextOffset = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 + moveInDuration + waitDuration) {
                let endOffset = geometry.size.width
                withAnimation(.easeIn(duration: moveOutDuration)) {
                    screenTextOffset = endOffset
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
                guard branchingMap[currentSceneId]?.sceneType == "screen" else {
                    print("Scene changed before 3s timer. Aborting automatic 'screen' transition.")
                    return
                }
                if current.nextSceneId.lowercased() == "end" {
                    return
                }
                guard let nextScene = branchingMap[current.nextSceneId] else {
                    return
                }
                if nextScene.isChoice == true {
                    isPopupVisible = true
                    currentChoiceScene = nextScene
                } else {
                    if nextScene.sceneType == "talk" || nextScene.sceneType == "chat" {
                        conversationHistory.append(nextScene)
                    }
                    currentSceneId = nextScene.sceneId
                }
            }
        }
    }
}
