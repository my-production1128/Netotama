//
//  ContentView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//

import SwiftUI


struct ContentView: View {
    // こいつ
    @State var netomoDialogues: [Dialogue] = []
    @State var groupchatDialogues: [Dialogue] = []
    @State private var kakusanDialogues: [Dialogue] = []
    
    @State var isMenuOpen = false
    // LottieViewの表示管理
    @State var isLottieViewVisible: Bool = true
    @State private var path = NavigationPath()
    
    //これ使ったらgameManager使える
    @StateObject private var gameManager = GameManager.shared
    @EnvironmentObject var musicplayer: SoundPlayer
    @GestureState private var isPressing = false

    @State private var stages: [StageData] = [
        StageData(id: 1, csvFileName: "bad_netomo_story1_ver8"),
        StageData(id: 2, csvFileName: "bad_netomo_story2_ver7")
//        StageData(id: 3, csvFileName: "bad_netomo_story3_ver2"),
//        StageData(id: 4, csvFileName: "bad_groupchat_story1_ver2"),
//        StageData(id: 5, csvFileName: "bad_groupchat_story2_ver2"),
//        StageData(id: 6, csvFileName: "bad_groupchat_story3_ver2"),
//        StageData(id: 7, csvFileName: "bad_kakusan_story1_ver2"),
//        StageData(id: 8, csvFileName: "bad_kakusan_story2_ver2"),
//        StageData(id: 9, csvFileName: "bad_kakusan_story3_ver2")
    ]
    
    // 全てのシナリオデータを保持する一つの配列
    @State var allBranchings: [Branching] = []
    @State var allScene: Branching = Branching(
        storyId: "",
        sceneId: "",
        sceneType: "",
        groupName: "",
        icon: "",
        characterName: "",
        leftCharacter: "",
        centerCharacter: "",
        rightCharacter: "",
        text: "",
        nextSceneId: "",
        isChoice: nil,
        choice1Text: "",
        choice1Percentage: nil,
        choice1NextSceneId: "",
        choice2Text: "",
        choice2Percentage: nil,
        choice2NextSceneId: "",
        choice3Text: "",
        choice3Percentage: nil,
        choice3NextSceneId: "",
        bgm: "",
        background: ""
    )
    
    @State private var animate = false

    @State private var currentMode: GameMode = .happy

    let floatingAnimation: Animation = Animation
        .easeInOut(duration: 2.0)
        .repeatForever(autoreverses: true)

    // ロゴのZStackを別のビューとして分離
    private var logoStackView: some View {
        ZStack {
            Image("conynonettodaiboukenn")
                .offset(x: animate ? 70: 75, y: animate ? -150 : -165)
                .animation(
                    floatingAnimation.delay(-0.7),
                    value: animate
                )

            Image("startlogo")
                .offset(x: animate ? 278: 287, y: animate ? -238 : -262)
                .animation(
                    floatingAnimation.delay(-0.7),
                    value: animate
                )

            Image("hitologo")
                .offset(x: animate ? -410: -408, y: animate ? -20 : -28)
                .animation(
                    floatingAnimation.delay(0.0),
                    value: animate
                )

            Image("dejitamalogonomi")
                .offset(y: animate ? -9 : -14)
                .animation(
                    floatingAnimation.delay(0.0),
                    value: animate
                )

            Image("hurtlogo")
                .offset(x: animate ? -350: -346, y: animate ? 98 : 80)
                .animation(
                    floatingAnimation.delay(0.3),
                    value: animate
                )

            Image("tamagologo")
                .offset(x: animate ? 270: 267, y: animate ? 98 : 65)
                .animation(
                    floatingAnimation.delay(-1.0),
                    value: animate
                )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                animate = true
            }
        }
    }
    
    // スタートボタンのビュー
    private var startButtonView: some View {
        Button {
            musicplayer.stopAllMusic()
            musicplayer.playSE(fileName: "startbutton_SE") {
                path.append(ViewBuilderPath.ChoiceView)
            }
        } label: {
            startButtonLabel
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.01)
                .updating($isPressing) { currentState, gestureState, transaction in
                    gestureState = currentState
                }
        )
    }
    
    // スタートボタンのラベル
    private var startButtonLabel: some View {
        Image("start")
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 100)
            .scaleEffect(isPressing ? 0.8 : 1.0)
            .shadow(
                color: Color.black.opacity(isPressing ? 0.2 : 0.4),
                radius: isPressing ? 1 : 5,
                x: isPressing ? 0 : 5,
                y: isPressing ? 0 : 5
            )
            .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: isPressing)
    }
    
    var body: some View {
            NavigationStack(path: $path) {
                ZStack {
                    Image("dejitama_startbackground")
                        .resizable()
                        .scaledToFill()

                    MenuView(isOpen: $isMenuOpen, path: $path)

                    VStack {
                        Spacer()
                        logoStackView.padding(80)
                        startButtonView
                        Spacer()
                    }
                }
                .onTapGesture {
                    musicplayer.stopAllMusic()
                    musicplayer.playSE(fileName: "startbutton_SE") {
                        path.append(ViewBuilderPath.ChoiceView)
                    }
                }
                .onAppear {
                    loadAllBranchingData()
                    musicplayer.stopAllMusic()
                    musicplayer.playBGM(fileName: "start_bgm")
                }
                .navigationDestination(for: ViewBuilderPath.self) { viewID in
                    destinationView(for: viewID)
                }
            }
        }

        // MARK: - View分割関数

        @ViewBuilder
        private func destinationView(for viewID: ViewBuilderPath) -> some View {
            switch viewID {
            case .ContentView:
                ContentView().environmentObject(gameManager)
            case .MapViewBad:
                MapView(path: $path, mode: .bad, currentMode: $currentMode)
                    .environmentObject(gameManager)
                    .navigationBarBackButtonHidden(true)
            case .MapViewHappy:
                MapView(path: $path, mode: .happy, currentMode: $currentMode)
                    .environmentObject(gameManager)
                    .navigationBarBackButtonHidden(true)
            case .GoodStoryBranchView(let storyId, let stageId, let mode):
                StoryBranchView(
                    path: $path,
                    allBranchings: $allBranchings,
                    allScene: $allScene,
                    StoryId: storyId,
                    stageId: stageId,
                    mode: mode,
                    currentMode: $currentMode
                )
                .environmentObject(gameManager)
                .navigationBarBackButtonHidden(true)
            case .ChoiceView:
                ChoiceView(path: $path)
                    .environmentObject(gameManager)
                    .navigationBarBackButtonHidden(true)
            case .Credit:
                Credit()
            case .HowToUse:
                HowToUse()
            case .StoryProgressView(let stageIndex):
                StoryProgressView(
                    dialogues: stages[stageIndex].dialogues,
                    initialSceneId: "Scene0",
                    currentMode: $currentMode,
                    path: $path
                )
                .environmentObject(gameManager)
                .navigationBarBackButtonHidden(true)
            case .ChatMessageView(let stageIndex, let initialSceneId):
                ChatMessageView(
                    dialogues: stages[stageIndex].dialogues,
                    initialSceneId: initialSceneId,
                    onNextScene: { _ in },
                    path: $path,
                    conversationHistory: .constant([]),
                    currentMode: $currentMode
                )
                .environmentObject(gameManager)
                .navigationBarBackButtonHidden(true)

            }
        }

        // MARK: - データ読み込み関数

        private func loadAllBranchingData() {
            for index in stages.indices {
                stages[index].loadDialogues()
            }
//            ネトモ
            let goodNetomoStory1 = loadBranchingCSV(fileName: "good_netomo_story1_ver5")
            let goodNetomoStory2 = loadBranchingCSV(fileName: "good_netomo_story2_ver3")
            let goodNetomoStory3 = loadBranchingCSV(fileName: "good_netomo_story3_ver2")

//            グルチャ
            let goodGuruchaStory1 = loadBranchingCSV(fileName: "good_gurucha_story1_ver5")
            let goodGuruchaStory2 = loadBranchingCSV(fileName: "good_gurucha_story2_ver6")
            let goodGuruchaStory3 = loadBranchingCSV(fileName: "good_gurucha_story3_ver2")
            self.allBranchings = goodNetomoStory1
                + goodNetomoStory2
                + goodNetomoStory3
                + goodGuruchaStory1
                + goodGuruchaStory2
                + goodGuruchaStory3
        }
    }

#Preview {
    ContentView()
        .environmentObject(SoundPlayer()) // SoundPlayerを提供
        .onAppear {
            // GameManagerの初期化確認
            _ = GameManager.shared
        }
}
