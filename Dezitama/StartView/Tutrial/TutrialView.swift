//
//  TutorialView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/07/19.
//

import SwiftUI
import Foundation
import UIKit

class TutorialManager {
    static let shared = TutorialManager()
    
    private init() {}
    
    // チュートリアルの表示状態を管理
    func hasSeenTutorial(for key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: "hasSeenTutorial_\(key)")
    }
    
    func setTutorialSeen(for key: String) {
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial_\(key)")
    }
    
    func resetTutorial(for key: String) {
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorial_\(key)")
    }
    
    func resetAllTutorials() {
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorial_choice")
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorial_map")
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorial_stage")
    }
}

// チュートリアルの表示タイプを定義
enum TutorialViewType {
    case type1  // タイプ1: 基本的な吹き出し表示
    case type2  // タイプ2: 異なるレイアウトの吹き出し
}

// チュートリアルの各ステップを定義
struct TutorialStep {
    let description: String  // ｜漢字《よみがな》形式で記述
    let viewType: TutorialViewType
    let backgroundImageName: String
    let cony: String
}

// MARK: - チュートリアル用ルビラベル（タイピングなし版）
struct TutorialRubyLabel: UIViewRepresentable {
    let text: String
    let font: UIFont
    let textColor: UIColor
    let textAlignment: NSTextAlignment
    let targetWidth: CGFloat
    
    func makeUIView(context: Context) -> WideRubyLabel {
        let label = WideRubyLabel()
        label.numberOfLines = 0
        label.textAlignment = textAlignment
        label.font = font
        label.textColor = textColor
        return label
    }
    
    func updateUIView(_ uiView: WideRubyLabel, context: Context) {
        uiView.font = font
        uiView.textColor = textColor
        uiView.textAlignment = textAlignment
        uiView.maxLayoutWidth = targetWidth
        uiView.preferredMaxLayoutWidth = targetWidth
        
        // String.createWideRuby()を使用してルビ付きテキストに変換
        uiView.attributedText = text.createWideRuby(font: font, color: textColor)
    }
}

// MARK: - 1. ChoiceView用のチュートリアル
struct ChoiceTutorialView: View {
    @Binding var isPresented: Bool
    
    let steps = [
        TutorialStep(
            description: "｜初《はじ》めまして！わたしはコニー！\nこれからこのゲームの｜遊《あそ》び｜方《かた》を｜説明《せつめい》していくよ！",
            viewType: .type1,
            backgroundImageName: "maeoki1",
            cony: "tutrial_cony02"
        ),
        TutorialStep(
            description: "このゲームは 2つのモードから｜遊《あそ》び｜方《かた》を｜選《えら》べるよ！",
            viewType: .type1,
            backgroundImageName: "maeoki1",
            cony: "tutrial_cony02"
        ),
        TutorialStep(
            description: "｜間違《まちが》い｜探検《たんけん》の｜旅《たび》では トラブルに｜巻《ま》き｜込《こ》まれていく\n｜体験《たいけん》ができるストーリーになってるよ！",
            viewType: .type2,
            backgroundImageName: "maeoki1",
            cony: "Bad_Button"
        ),
        TutorialStep(
            description: "ストーリーの｜途中《とちゅう》に｜出《で》てくる｜選択肢《せんたくし》の｜中《なか》で、\nより｜間違《まちが》ってる｜方《ほう》を｜選《えら》んで｜雷《かみなり》ポイントを｜稼《かせ》ごう！",
            viewType: .type2,
            backgroundImageName: "maeoki1",
            cony: "Bad_Button"
        ),
        TutorialStep(
            description: "｜ 情報《じょうほう》モラルマスターの｜旅《たび》では、\n｜自分《じぶん》でより｜良《よ》い｜選択肢《せんたくし》を｜選《えら》んでトラブルを｜解決《かいけつ》しよう！",
            viewType: .type2,
            backgroundImageName: "maeoki1",
            cony: "Good_Button"
        ),
        TutorialStep(
            description: "より｜良《よ》い｜選択肢《せんたくし》を｜選《えら》ぶと｜星《ほし》ポイントが｜溜《た》まるよ！",
            viewType: .type2,
            backgroundImageName: "maeoki1",
            cony: "Good_Button"
        ),
        TutorialStep(
            description: "まずは｜間違《まちが》い｜探検《たんけん》の｜旅《たび》に｜進《すす》んでみよう！",
            viewType: .type2,
            backgroundImageName: "maeoki1",
            cony: "Bad_Button"
        )
    ]
    
    @State private var currentIndex = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        TutorialContentView(steps: steps, currentIndex: $currentIndex, onComplete: {
            TutorialManager.shared.setTutorialSeen(for: "choice")
            withAnimation {
                isPresented = false
            }
        })
    }
}

// MARK: - 2. MapView用のチュートリアル
struct MapTutorialView: View {
    @Binding var isPresented: Bool
    
    let steps = [
        TutorialStep(
            description: "｜前《まえ》の｜島《しま》のストーリーを｜体験《たいけん》して｜雷《かみなり》or ｜星《ほし》を｜貯《た》めたら、\n｜次《つぎ》の｜島《しま》に｜進《すす》めるようになってるよ！",
            viewType: .type2,
            backgroundImageName: "maeoki2",
            cony: ""
        ),
        TutorialStep(
            description: "｜全部《ぜんぶ》の｜島《しま》で｜集《あつ》めた｜星《ほし》・｜雷《かみなり》の｜数《かず》は｜右上《みぎうえ》で｜確認《かくにん》できるよ！",
            viewType: .type2,
            backgroundImageName: "maeoki_mark",
            cony: ""
        ),
        TutorialStep(
            description: "ここはグルチャ｜島《とう》！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_groupchat",
            cony: ""
        ),
        TutorialStep(
            description: "この｜島《しま》は、グループチャットでちょっとしたトラブルが\n｜起《お》きる｜島《しま》なんだ！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_groupchat",
            cony: ""
        ),
        TutorialStep(
            description: "｜早速《さっそく》ストーリーを｜始《はじ》めてみよう！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_groupchat",
            cony: ""
        )
    ]
    
    @State private var currentIndex = 0
    
    var body: some View {
        TutorialContentView(steps: steps, currentIndex: $currentIndex, onComplete: {
            TutorialManager.shared.setTutorialSeen(for: "map")
            withAnimation {
                isPresented = false
            }
        })
    }
}

// MARK: - 3. ステージ開放時のチュートリアル
struct StageUnlockTutorialView1: View {
    let steps: [TutorialStep] = [
        TutorialStep(
            description: "｜君《きみ》の｜頑張《がんば》りによって、\n ｜情報《じょうほう》モラルマスターの｜旅《たび》のグルチャ｜島《とう》と",
            viewType: .type2,
            backgroundImageName: "maeoki_good_groupchat",
            cony: ""
        ),
        TutorialStep(
            description: "｜間違《まちが》い｜探検《たんけん》の｜旅《たび》のネトモ｜島《とう》が｜開放《かいほう》されたよ！！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_netomo",
            cony: ""
        ),
        TutorialStep(
            description: "ここは、ネトモ｜島《とう》！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_netomo",
            cony: ""
        ),
        TutorialStep(
            description: "この｜島《しま》は、ネットで｜知《し》り｜合《あ》ったネトモとの\nトラブルが｜起《お》きる｜島《しま》なんだ！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_netomo",
            cony: ""
        ),
        TutorialStep(
            description: "さっそく｜開放《かいほう》されたステージをプレイしてみよう！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_netomo",
            cony: ""
        )
    ]
    
    @State private var currentIndex = 0
    @Binding var isPresented: Bool
    
    var body: some View {
        TutorialContentView(steps: steps, currentIndex: $currentIndex, onComplete: {
            TutorialManager.shared.setTutorialSeen(for: "stage_unlock_1")
            withAnimation {
                isPresented = false
            }
        })
    }
}

// MARK: - 4. ステージ開放時のチュートリアル
struct StageUnlockTutorialView2: View {
    let steps: [TutorialStep] = [
        TutorialStep(
            description: "｜君《きみ》の｜頑張《がんば》りによって、\n ｜情報《じょうほう》モラルマスターの｜旅《たび》のネトモ｜島《とう》と",
            viewType: .type2,
            backgroundImageName: "maeoki_good_netomo",
            cony: ""
        ),
        TutorialStep(
            description: "｜間違《まちが》い｜探検《たんけん》の｜旅《たび》のシェア｜島《とう》が｜開放《かいほう》されたよ！！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_share",
            cony: ""
        ),
        TutorialStep(
            description: "ここは、シェア｜島《とう》だよ！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_share",
            cony: ""
        ),
        TutorialStep(
            description: "この｜島《しま》は、｜軽《かる》い｜気持《きも》ちで｜動画《どうが》を\n｜共有《きょうゆう》したことからトラブルが｜起《お》きる｜島《しま》なんだ！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_share",
            cony: ""
        ),
        TutorialStep(
            description: "さっそく｜開放《かいほう》されたステージをプレイしてみよう！",
            viewType: .type2,
            backgroundImageName: "maeoki_bad_share",
            cony: ""
        )
    ]
    
    @State private var currentIndex = 0
    @Binding var isPresented: Bool
    
    var body: some View {
        TutorialContentView(steps: steps, currentIndex: $currentIndex, onComplete: {
            TutorialManager.shared.setTutorialSeen(for: "stage_unlock_2")
            withAnimation {
                isPresented = false
            }
        })
    }
}

// MARK: - 共通のチュートリアル表示コンポーネント
struct TutorialContentView: View {
    let steps: [TutorialStep]
    @Binding var currentIndex: Int
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // 背景画像
            Image(steps[currentIndex].backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 30) {
                Spacer()
                
                // メインコンテンツ - タイプ別に表示を切り替え
                contentView(for: steps[currentIndex])
                    .id(currentIndex)
                
                Spacer()
                
                Spacer()
                    .frame(height: 30)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if currentIndex < steps.count - 1 {
                    currentIndex += 1
                } else {
                    onComplete()
                }
            }
        }
    }
    
    // MARK: - コンテンツ表示の切り替え
    @ViewBuilder
    private func contentView(for step: TutorialStep) -> some View {
        switch step.viewType {
        case .type1:
            SpeechBubbleView(text: step.description, bubbleColor: .white, viewType: .type1, conyImageName: step.cony)
                .padding(.horizontal, 30)
                .transition(.opacity)
            
        case .type2:
            VStack {
                SpeechBubbleView(text: step.description, bubbleColor: .white, viewType: .type2, conyImageName: step.cony)
                    .padding(.horizontal, 30)
                Spacer()
            }
            .padding(.top, 50)
            .transition(.opacity)
        }
    }
}

// MARK: - 吹き出しコンポーネント
struct SpeechBubbleView: View {
    let text: String
    let bubbleColor: Color
    let viewType: TutorialViewType
    let conyImageName: String
    
    @State private var offsetY: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            switch viewType {
            case .type1:
                ZStack {
                    VStack{
                        Image(conyImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                    }
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.55)
                    
                    ZStack {
                        Image("tutrial_hukidashi01")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.75)
                        
                        TutorialRubyLabel(
                            text: text,
                            font: UIFont(name: "MPLUS1-Bold", size: 28) ?? .systemFont(ofSize: 28),
                            textColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
                            textAlignment: .center,
                            targetWidth: geometry.size.width * 1
                        )
                        .frame(width: geometry.size.width * 1)
                        .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.55)
                        
                        Image("next_button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .position(x: geometry.size.width * 0.82,y: geometry.size.height * 0.63)
                            .offset(y: offsetY)
                            .onAppear {
                                startLoopingAnimation()
                            }
                    }
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.9)
                }
                
            case .type2:
                ZStack {
                    VStack{
                        Image(conyImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.4)
                    }
                    
                    HStack(spacing: 3) {
                        Image("maeoki_aikon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.15)
                        
                        ZStack {
                            Image("tutrial_hukidashi02")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.75)
                            
                            TutorialRubyLabel(
                                text: text,
                                font: UIFont(name: "MPLUS1-Bold", size: 28) ?? .systemFont(ofSize: 28),
                                textColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
                                textAlignment: .center,
                                targetWidth: geometry.size.width * 0.65
                            )
                            .frame(width: geometry.size.width * 0.65)
                            
                            Image("next_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .position(x: geometry.size.width * 0.75,y: geometry.size.height * 0.55)
                                .offset(y: offsetY)
                                .onAppear {
                                    startLoopingAnimation()
                                }
                        }
                    }
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.95)
                }
            }
        }
    }
    
    private func startLoopingAnimation() {
        offsetY = 0.0
        let animation = Animation
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)

        withAnimation(animation) {
            offsetY = 8.0
        }
    }
}

// プレビュー
#Preview("Choice_Tutorial") {
    ChoiceTutorialView(isPresented: .constant(true))
}

#Preview("Map_Tutorial") {
    MapTutorialView(isPresented: .constant(true))
}

#Preview("Stage_Unlock_Tutorial1") {
    StageUnlockTutorialView1(isPresented: .constant(true))
}

#Preview("Stage_Unlock_Tutorial2") {
    StageUnlockTutorialView2(isPresented: .constant(true))
}
