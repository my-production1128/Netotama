//
//  StorylineView.swift (StoryBranchView.swiftファイル内に追加)
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/27.
//

import SwiftUI

struct StorylineView: View {

    // MARK: - Properties
    // 親Viewからのデータ
    let current: Branching
    let geometry: GeometryProxy
    let talkFont: UIFont
    let branchingMap: [String: Branching]
    let offsetY: CGFloat
    let startLoopingAnimation: () -> Void
    // 親Viewと同期するState
    @Binding var currentSceneId: String
    @Binding var currentChoiceScene: Branching?
    @Binding var isPopupVisible: Bool
    @Binding var conversationHistory: [Branching]
    @Binding var storylineOpacity: Double
    @Binding var isStorylineInteractable: Bool

    // EnvironmentObject
    @EnvironmentObject var musicplayer: SoundPlayer

    // MARK: - Body

    var body: some View {
        ZStack {
            WideRubyLabelRepresentable(
                attributedText: current.text
                    .replacingOccurrences(of: "<br>", with: "\n")
                    .createWideRuby(font: talkFont, color: .black),
                font: talkFont,
                textColor: .black,
                textAlignment: .center,
                targetWidth: 700
            )
            .frame(maxWidth: 750)
            .padding(.bottom, 270)
            .opacity(storylineOpacity)
            .onAppear {
                let sceneToDisplay = currentChoiceScene ?? branchingMap[currentSceneId]
                if let current = sceneToDisplay {
                    musicplayer.playBGM(fileName: current.bgm)
                }
                storylineOpacity = 0.0
                isStorylineInteractable = false
                let animationDuration = 1.0
                withAnimation(.easeIn(duration: animationDuration)) {
                    storylineOpacity = 1.0
                }completion: {
                    if branchingMap[currentSceneId]?.sceneType == "storyline" {
                        isStorylineInteractable = true
                        print("Storylineのタップが可能になりました。")
                    }
                }
            }
            .onChange(of: currentSceneId) { _, newSceneId in
                if let newScene = branchingMap[newSceneId] {
                    if newScene.sceneType == "storyline" {
                        storylineOpacity = 0.0
                        isStorylineInteractable = false
                        let animationDuration = 1.0
                        withAnimation(.easeIn(duration: animationDuration)) {
                            storylineOpacity = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                            if branchingMap[currentSceneId]?.sceneType == "storyline" {
                                isStorylineInteractable = true
                                print("Storylineのタップが可能になりました。")
                            }
                        }
                    } else {
                        storylineOpacity = 1.0
                        isStorylineInteractable = true
                    }
                }
            }

            HStack {
                Image("next_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
                    .position(x: geometry.size.width * 0.85,y: geometry.size.height * 0.905)
                    .offset(y: offsetY)
                    .onAppear {
                        startLoopingAnimation() //
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isStorylineInteractable else {
                print("Storylineアニメーション中のためタップを無視しました。")
                return
            }

            if current.nextSceneId.lowercased() == "end" {
                return
            }

            guard let nextScene = branchingMap[current.nextSceneId] else {
                return
            }

            musicplayer.playSE(fileName: "button_SE_2")
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
