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
    
    @State private var animate = false
    
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack{
//                if isLottieViewVisible{
//                    LottieView(filename: "StartAnimation")
//                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//                        .edgesIgnoringSafeArea(.all)
//                }
                
                Image("dejitama_startbackground")
                    .resizable()
                    .scaledToFill()
                    
                
                MenuView(isOpen: $isMenuOpen, path: $path)
                
                VStack{
                    Spacer()
                    
                    Image("dejitama_logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 450, height: 450)
                        .offset(y: animate ? 0 : -40)
                        .onAppear {
                            // 最初は真ん中に配置してからアニメーションを開始
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                animate = true
                            }
                        }
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: animate
                        )
                    
//                    Spacer()
                   
                    Image("start")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 100)
                    
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
