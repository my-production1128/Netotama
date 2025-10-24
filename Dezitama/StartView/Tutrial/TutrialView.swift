//
//  TutorialView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/07/19.
//
import SwiftUI
import Foundation

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
    let description: String
    let viewType: TutorialViewType
    let backgroundImageName: String
    let cony: String
}

// MARK: - 1. ChoiceView用のチュートリアル
struct ChoiceTutorialView: View {
    @Binding var isPresented: Bool
    
    let steps = [
        TutorialStep(
            description: "初めまして！わたしはコニー！\nこれからこのゲームの遊び方を説明していくよ！",
            viewType: .type1,
            backgroundImageName: "maeoki1",
            cony: "tutrial_cony02"
        ),
        TutorialStep(
            description: "2つのモードから遊び方を選べるよ！",
            viewType: .type1,
            backgroundImageName: "maeoki1",
            cony: "tutrial_cony02"
        ),
        TutorialStep(
            description: "間違い探検の旅ではトラブルに巻き込まれていく\n体験ができるストーリーになってるよ！",
            viewType: .type2,
            backgroundImageName: "maeoki1",
            cony: "Bad_Button"
        ),
        TutorialStep(
            description: "ストーリーの途中に出てくる選択肢の中で、\nより間違ってる方を選んで雷ポイントを稼ごう！",
            viewType: .type2,
            backgroundImageName: "maeoki1",
            cony: "Bad_Button"
        ),
        TutorialStep(
            description: "情報モラルマスターの旅では、\n自分でより良い選択肢を選んでトラブルを解決しよう！",
            viewType: .type2,
            backgroundImageName: "maeoki1",
            cony: "Good_Button"
        ),
        TutorialStep(
            description: "より良い選択肢を選ぶと星ポイントが溜まるよ！",
            viewType: .type2,
            backgroundImageName: "maeoki1",
            cony: "Good_Button"
        ),
        TutorialStep(
            description: "まずは間違い探検の旅に進んでみよう！",
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
                isPresented = false  // これでChoiceViewに戻る
            }
        })
    }
}

// MARK: - 2. MapView用のチュートリアル
struct MapTutorialView: View {
    @Binding var isPresented: Bool
    
    let steps = [
        TutorialStep(
            description: "前の島のストーリーを体験したら、\n次の島に進めるようになってるよ！",
            viewType: .type2,
            backgroundImageName: "maeoki2",
            cony: ""
        ),
        TutorialStep(
            description: "全部の島で集めた星・雷の数は右上で確認できるよ！",
            viewType: .type2,
            backgroundImageName: "maeoki2",
            cony: ""
        ),
        TutorialStep(
            description: "グルチャ島では、グループチャットでの悪口が\nきっかけに起きるトラブルの物語だよ！",
            viewType: .type2,
            backgroundImageName: "maeoki_groupchat",
            cony: ""
        ),
        TutorialStep(
            description: "早速ストーリーを始めてみよう！",
            viewType: .type2,
            backgroundImageName: "maeoki_groupchat",
            cony: ""
        )
    ]
    
    @State private var currentIndex = 0
    
    var body: some View {
        TutorialContentView(steps: steps, currentIndex: $currentIndex, onComplete: {
            TutorialManager.shared.setTutorialSeen(for: "map")
            withAnimation {
                isPresented = false  // これでMapViewに留まる
            }
        })
    }
}

// MARK: - 3. ステージ開放時のチュートリアル（将来用）
struct StageUnlockTutorialView1: View {
    let steps: [TutorialStep] = [
        // 後で島ごとのチュートリアルを追加
        TutorialStep(
            description: "君の頑張りによって、ネトモ島が開放されたよ！",
            viewType: .type2,
            backgroundImageName: "maeoki_netomo",
            cony: ""
        ),
        TutorialStep(
            description: "ネトモ島は、ネットで知り合った”ネトモ”とのトラブルの物語だよ！",
            viewType: .type2,
            backgroundImageName: "maeoki_netomo",
            cony: ""
        ),
        TutorialStep(
            description: "ネトモ島に行ってみよう！",
            viewType: .type2,
            backgroundImageName: "maeoki_netomo",
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

// MARK: - 4. ステージ開放時のチュートリアル（将来用）
struct StageUnlockTutorialView2: View {
    let steps: [TutorialStep] = [
        TutorialStep(
            description: "君の頑張りでシェア島が開放されたよ！",
            viewType: .type2,
            backgroundImageName: "maeoki_share",
            cony: ""
        ),
        TutorialStep(
            description: "シェア島は、軽い気持ちで動画をみんなに\n共有したことから始まるトラブルの物語だよ！",
            viewType: .type2,
            backgroundImageName: "maeoki_share",
            cony: ""
        ),
        TutorialStep(
            description: "シェア島に行ってみよう！",
            viewType: .type2,
            backgroundImageName: "maeoki_share",
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
                
                // ボタン
                VStack(spacing: 15) {
                    //
                }
                
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
        case .type1: //image真ん中
            SpeechBubbleView(text: step.description, bubbleColor: .white, viewType: .type1, conyImageName: step.cony)
                .padding(.horizontal, 30)
                .transition(.opacity)
            
        case .type2: //コニーアイコン付き
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
            // viewTypeによって異なる吹き出し画像を表示
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
                        
                        Text(text)
                            .font(.custom("MPLUS1-Bold", size: 28))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .frame(width: geometry.size.width * 1)
                            .multilineTextAlignment(.center)
                        
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
                    
                    // 吹き出し部分
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
                            
                            Text(text)
                                .font(.custom("MPLUS1-Bold", size: 28))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .frame(width: geometry.size.width * 0.65)
                                .multilineTextAlignment(.center)
                            
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
