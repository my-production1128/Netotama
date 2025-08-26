//
//  TalkingView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/08/18.
//

import SwiftUI

struct TalkingView: View {
    // MARK: - Properties
    let current: Dialogue
    let geometry: GeometryProxy
    
    // MARK: - Bindings
    @Binding var offsetY: CGFloat
    
    // MARK: - Actions
    let onSceneTap: () -> Void
    let onStartLoopingAnimation: () -> Void
    
    // MARK: - Constants
    private let talkFont = UIFont.customFont(ofSize: 30)
    private let charaNameFont = UIFont.customFont(ofSize: 35)
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景
            if current.background == "Park" {
                CommonUIComponents.backgroundImage("park")
            } else if current.background == "Classroom" {
                CommonUIComponents.backgroundImage("classroom")
            } else if current.background == "News" {
                CommonUIComponents.backgroundImage("news")
            } else {
                CommonUIComponents.backgroundImage("my_room")
            }
            
            // TalkingPeopleに基づいてキャラクターを配置
            characterLayoutView
            
            // ダイアログコンポーネントグループ
            dialogueComponentsGroup
        }
        .onTapGesture(perform: onSceneTap)
    }
    
    // MARK: - Character Layout View
    @ViewBuilder
    private var characterLayoutView: some View {
        switch current.safeTalkingPeople {
        case "Three":
            threePersonLayout
        case "Two":
            twoPersonLayout
        case "One":
            onePersonLayout
        default:
            EmptyView()
        }
    }
    
    // MARK: - 3人レイアウト
    private var threePersonLayout: some View {
        Group {
            // 左のキャラクター
            if !current.safeLeftCharacter.isEmpty {
                characterImage(
                    current.safeLeftCharacter,
                    width: getCharacterSize(for: current.safeLeftCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).width,
                    height: getCharacterSize(for: current.safeLeftCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).height,
                    isSpeaking: isCharacterSpeaking(current.safeLeftCharacter, speakerName: current.characterName)
                )
                .offset(x: -300)
                .animation(.easeInOut(duration: 0.3), value: isCharacterSpeaking(current.safeLeftCharacter, speakerName: current.characterName))
            }
            
            // 中央のキャラクター
            if !current.safeCenterCharacter.isEmpty {
                characterImage(
                    current.safeCenterCharacter,
                    width: getCharacterSize(for: current.safeCenterCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).width,
                    height: getCharacterSize(for: current.safeCenterCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).height,
                    isSpeaking: isCharacterSpeaking(current.safeCenterCharacter, speakerName: current.characterName)
                )
                .offset(x: 0)
                .animation(.easeInOut(duration: 0.3), value: isCharacterSpeaking(current.safeCenterCharacter, speakerName: current.characterName))
            }
            
            // 右のキャラクター
            if !current.safeRightCharacter.isEmpty {
                characterImage(
                    current.safeRightCharacter,
                    width: getCharacterSize(for: current.safeRightCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).width,
                    height: getCharacterSize(for: current.safeRightCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).height,
                    isSpeaking: isCharacterSpeaking(current.safeRightCharacter, speakerName: current.characterName)
                )
                .offset(x: 300)
                .animation(.easeInOut(duration: 0.3), value: isCharacterSpeaking(current.safeRightCharacter, speakerName: current.characterName))
            }
        }
    }
    
    // MARK: - 2人レイアウト
    private var twoPersonLayout: some View {
        HStack {
            // OneCharacter（左側）
            if !current.safeOneCharacter.isEmpty {
                characterImage(
                    current.safeOneCharacter,
                    width: getCharacterSize(for: current.safeOneCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).width,
                    height: getCharacterSize(for: current.safeOneCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).height,
                    isSpeaking: isCharacterSpeaking(current.safeOneCharacter, speakerName: current.characterName)
                )
                .offset(x: -100)
                .animation(.easeInOut(duration: 0.3), value: isCharacterSpeaking(current.safeOneCharacter, speakerName: current.characterName))
            }
            
            // TwoCharacter（右側）
            if !current.safeTwoCharacter.isEmpty {
                characterImage(
                    current.safeTwoCharacter,
                    width: getCharacterSize(for: current.safeTwoCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).width,
                    height: getCharacterSize(for: current.safeTwoCharacter, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).height,
                    isSpeaking: isCharacterSpeaking(current.safeTwoCharacter, speakerName: current.characterName)
                )
                .offset(x: 100)
                .animation(.easeInOut(duration: 0.3), value: isCharacterSpeaking(current.safeTwoCharacter, speakerName: current.characterName))
            }
        }
    }
    
    // MARK: - 1人レイアウト
    private var onePersonLayout: some View {
        Group {
            if !current.safeOnePerson.isEmpty {
                characterImage(
                    current.safeOnePerson,
                    width: getCharacterSize(for: current.safeOnePerson, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).width,
                    height: getCharacterSize(for: current.safeOnePerson, speaking: current.characterName, talkingPeople: current.safeTalkingPeople).height,
                    isSpeaking: isCharacterSpeaking(current.safeOnePerson, speakerName: current.characterName)
                )
                .animation(.easeInOut(duration: 0.3), value: isCharacterSpeaking(current.safeOnePerson, speakerName: current.characterName))
            }
        }
    }
    
    // MARK: - キャラクターが話し手かどうかの判定（改善版）
    private func isCharacterSpeaking(_ imageName: String, speakerName: String) -> Bool {
        let characterName = getCharacterNameFromImage(imageName)
        return characterName == speakerName
    }
    
    // MARK: - キャラクターサイズ計算
    private func getCharacterSize(for imageName: String, speaking characterName: String, talkingPeople: String) -> (width: CGFloat, height: CGFloat) {
        let isSpeaking = isCharacterSpeaking(imageName, speakerName: characterName)
        let baseSize = getBaseCharacterSize(for: imageName)
        let multiplier: CGFloat = isSpeaking ? 1.2 : 1.0 // 話し手は20%大きく
        
        return (
            width: baseSize.width * multiplier,
            height: baseSize.height * multiplier
        )
    }
    
    private func getBaseCharacterSize(for imageName: String) -> (width: CGFloat, height: CGFloat) {
        // 表情のサフィックスを除去してベースキャラクター名を取得
        let baseCharacterName = extractBaseCharacterName(from: imageName)
        
        switch baseCharacterName {
        case "Alec": return (250, 650)
        case "Cecil": return (250, 450)
        case "Cony": return (250, 450)
        case "Curl": return (250, 550)
        case "Teacher": return (300, 450)
        case "Brian": return (300, 450)
        case "Nick" : return (250, 650)
        case "Sandra": return (250, 250)
        default: return (250, 450)
        }
    }

    private func extractBaseCharacterName(from imageName: String) -> String {
        // "_"で区切って最初の部分を取得（例: "Alec_happy" → "Alec"）
        return imageName.components(separatedBy: "_").first ?? imageName
    }
    
    // MARK: - 画像名からキャラクター名を取得（改善版）
    private func getCharacterNameFromImage(_ imageName: String) -> String {
        // 表情のサフィックスを除去してベース名を取得
        let baseName = extractBaseCharacterName(from: imageName)
        
        switch baseName {
        case "Alec":
            return "アレック"
        case "Cecil":
            return "セシル"
        case "Cony":
            return "コニー"
        case "Curl":
            return "カール"
        case "Teacher":
            return "先生"
        case "Nick":
            return "ニック"
        case "Sandra":
            return "サンドラ"
        case "Brian":
            return "ブライアン"
        default:
            // デバッグ用：不明なキャラクター名をログ出力
            print("未知のキャラクター名: \(imageName) (ベース名: \(baseName))")
            return ""
        }
    }
    
    // MARK: - Dialogue Components Group
    private var dialogueComponentsGroup: some View {
        Group {
            // 吹き出し背景
            Image("speech_bubble_beige")
                .resizable()
                .frame(width: 1000, height: 300)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.8)
            
            // キャラ名ラベル
            Text(current.characterName)
                .font(Font(UIFont.customFont(ofSize: 30)))
                .foregroundColor(.black)
                .position(x: geometry.size.width * 0.22, y: geometry.size.height * 0.673)
            
            // セリフテキスト（ルビ対応）- キー変更でリフレッシュ
            TypingRubyLabelRepresentable(
                attributedText: current.dialogueText
                    .replacingOccurrences(of: "<br>", with: "\n")
                    .createWideRuby(font: UIFont.customFont(ofSize: 30), color: .black),
                charInterval: 0.05,
                font: UIFont.customFont(ofSize: 30)
            )
            .frame(maxWidth: 700)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)
            .id(current.dialogueText) // キー変更でTypingRubyLabelRepresentableを再作成
            
            // ナビゲーションボタン（アニメーション付き）
            Button(action: onSceneTap) {
                Image("next_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
            }
            .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.905)
            .offset(y: offsetY)
            .onAppear {
                onStartLoopingAnimation()
            }
        }
        .offset(y: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
    
    // MARK: - Reusable Components
    private func backgroundImage(_ imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    private func characterImage(_ imageName: String, width: CGFloat, height: CGFloat, isSpeaking: Bool = false) -> some View {
        Image(imageName)
            .resizable()
            .frame(width: width, height: height)
            .saturation(isSpeaking ? 1.0 : 0.7) // 彩度を30%に下げる
            .brightness(isSpeaking ? 0.0 : -0.2) // 明るさを20%下げる
            .scaleEffect(isSpeaking ? 1.0 : 0.95) // 話し手以外は少し小さく
    }
}

// MARK: - Dialogue Extension (CSV用)
extension Dialogue {
    var safeLeftCharacter: String {
        return self.leftCharacter ?? ""
    }
    
    var safeCenterCharacter: String {
        return self.centerCharacter ?? ""
    }
    
    var safeRightCharacter: String {
        return self.rightCharacter ?? ""
    }
    
    var safeOneCharacter: String {
        return self.oneCharacter ?? ""
    }
    
    var safeTwoCharacter: String {
        return self.twoCharacter ?? ""
    }
    
    var safeOnePerson: String {
        return self.onePerson ?? ""
    }
    
    var safeTalkingPeople: String {
        return self.talkingPeople ?? ""
    }
    
    var leftCharacterEnum: CharacterName? {
        CharacterName(rawValue: safeLeftCharacter)
    }
    
    var centerCharacterEnum: CharacterName? {
        CharacterName(rawValue: safeCenterCharacter)
    }
    
    var rightCharacterEnum: CharacterName? {
        CharacterName(rawValue: safeRightCharacter)
    }
    
    var oneCharacterEnum: CharacterName? {
        CharacterName(rawValue: safeOneCharacter)
    }
    
    var twoCharacterEnum: CharacterName? {
        CharacterName(rawValue: safeTwoCharacter)
    }
    
    var onePersonEnum: CharacterName? {
        CharacterName(rawValue: safeOnePerson)
    }
}
