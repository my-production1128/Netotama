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
        StageData(id: 1, csvFileName: "bad_netomo_story1_ver7"),
//        StageData(id: 2, csvFileName: "stage2_groupchat"),
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

    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack{
                
                Image("dejitama_startbackground")
                    .resizable()
                    .scaledToFill()
                    
                
                MenuView(isOpen: $isMenuOpen, path: $path)
                
                VStack{
                    Spacer()
                    

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
                        .padding(80)

                    Button {
                        musicplayer.stopAllMusic()
                        musicplayer.playSE(fileName: "startbutton_SE") {
                            path.append(ViewBuilderPath.ChoiceView)
                        }
                    } label: {
                        Image("start")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 100)
                            .scaleEffect(isPressing ? 0.8 : 1.0)
                            .shadow(color: Color.black.opacity(isPressing ? 0.2 : 0.4),
                                    radius: isPressing ? 1 : 5,
                                    x: isPressing ? 0 : 5,
                                    y: isPressing ? 0 : 5)
                            .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: isPressing)
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.01)
                            .updating($isPressing) { currentState, gestureState, transaction in
                                gestureState = currentState
                            }
                    )
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        //isMenuOpenの変化にアニメーションをつける
//                        withAnimation(.easeInOut(duration: 0.3)) {
//                            isMenuOpen.toggle()
//                        }
//                    } label: {
//                        Image("imark")
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 50, height: 50)
//                    }
                }
            }
            .onTapGesture {
                musicplayer.stopAllMusic()
                musicplayer.playSE(fileName: "startbutton_SE") {
                    path.append(ViewBuilderPath.ChoiceView)
                }
            }

            .onAppear {
                for index in stages.indices {
                        stages[index].loadDialogues()
                    }
                let goodNetomoStory1 = loadBranchingCSV(fileName: "good_netomo_story1_ver5")
                let goodNetomoStory2 = loadBranchingCSV(fileName: "good_netomo_story2_ver3")
                let goodNetomoStory3 = loadBranchingCSV(fileName: "good_netomo_story3_ver1")
                self.allBranchings = goodNetomoStory1 + goodNetomoStory2 + goodNetomoStory3

//                BGMの再生
                musicplayer.stopAllMusic()
                musicplayer.playBGM(fileName: "start_bgm")
            }
            .navigationDestination(for: ViewBuilderPath.self) { viewID in
                switch viewID {
                case .ContentView:
                    ContentView()
                        .environmentObject(gameManager)
                    
                case .MapViewBad:
                    MapView(path: $path, mode: .bad,currentMode: $currentMode)
                        .environmentObject(gameManager)
                        .navigationBarBackButtonHidden(true)
                    
                case .MapViewHappy:
                    MapView(path: $path, mode: .happy,currentMode: $currentMode)
                        .environmentObject(gameManager)
                        .navigationBarBackButtonHidden(true)
                    
                case .GoodStoryBranchView(let StoryId, let stageId, let mode):
                    StoryBranchView(path: $path,
                                    allBranchings: $allBranchings,
                                    allScene: $allScene,
                                    StoryId: StoryId,
                                    stageId: stageId,
                                    mode: mode,
                                    currentMode: $currentMode
                    )
                    .environmentObject(gameManager)
                    .navigationBarBackButtonHidden(true)
                    
                case .GroupchatView:
                    GroupchatView(path: $path, groupchatDialogues: $groupchatDialogues)
                        .environmentObject(gameManager)
                        .navigationBarBackButtonHidden(true)
                    
                case .kakusanView:
                    KakusanView(path: $path, kakusanDialogues: $kakusanDialogues)
                        .environmentObject(gameManager)
                        .navigationBarBackButtonHidden(true)
                    
                case .NetomoView:
                    NetomoView(path: $path, netomoDialogues: $netomoDialogues)
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
                            initialSceneId: "Scene0", currentMode: $currentMode
                        )
                        .environmentObject(gameManager)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
//    ContentView()
}
