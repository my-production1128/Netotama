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
        choice1Type: "",
        choice1Percentage: nil,
        choice1NextSceneId: "",
        choice2Text: "",
        choice2Type: "",
        choice2Percentage: nil,
        choice2NextSceneId: "",
        choice3Text: "",
        choice3Type: "",
        choice3Percentage: nil,
        choice3NextSceneId: "",
        bgm: "",
        background: ""
    )
    var body: some View {
        NavigationStack(path: $path) {
            ZStack{
                Color(red: 0.68, green: 0.93, blue: 0.93)
                    .ignoresSafeArea()
                
                if isLottieViewVisible{
                    LottieView(filename: "egg_start_ver5_0")
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all)
                }
                MenuView(isOpen: $isMenuOpen, path: $path)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        //isMenuOpenの変化にアニメーションをつける
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isMenuOpen.toggle()
                        }
                    } label: {
                        Image("imark")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .onTapGesture {
                path.append(ViewBuilderPath.ChoiceView)
            }
            //csvファイルの読み込み
            .onAppear {
                netomoDialogues = loadCSV(fileName: "netomo_ver10_0")
                groupchatDialogues = loadCSV(fileName: "groupchat_ver11_0")
                kakusanDialogues = loadCSV(fileName: "kakusan_ver9_0")
                let goodNetomoStory1 = loadBranchingCSV(fileName: "good_netomo_story1_ver1")
                //                let netomoBranchings = loadBranchingCSV(fileName: "netomo_branch_ver23")
                //                let groupBranchings = loadBranchingCSV(fileName: "groupchat_branch_ver14")
                //                let kakusanBranchings = loadBranchingCSV(fileName: "kakusan_branch_ver4")
                self.allBranchings = goodNetomoStory1
                
                //デバック用ステージ全解放
                gameManager.setDebugUnlockAll()
            }
            .navigationDestination(for: ViewBuilderPath.self) { viewID in
                switch viewID {
                case .ContentView:
                    ContentView()
                    
                case .MapViewBad:
                    MapView(path: $path, mode: .bad)
                        .environmentObject(gameManager)
                        .navigationBarBackButtonHidden(true)
                    
                case .MapViewHappy:
                    MapView(path: $path, mode: .happy)
                        .environmentObject(gameManager)
                        .navigationBarBackButtonHidden(true)
                    
                case .GoodStoryBranchView(let StoryId):
                    StoryBranchView(path: $path,
                                    allBranchings: $allBranchings,
                                    allScene: $allScene,
                                    StoryId: StoryId
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
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
