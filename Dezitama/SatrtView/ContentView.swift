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
//    @State private var isTextVisible: Bool = false// テキストの点滅


    // 全てのシナリオデータを保持する一つの配列
    @State var allBranchings: [Branching] = []
    @State var allScene: Branching = Branching(
        storyId: "", sceneId: "", sceneType: "",icon: "", characterName: "", leftCharacter: "", rightCharacter: "", text: "",
        background: "",speechBubble: "", nextSceneId: "", isChoice: nil,
        choiceText1: "", choiceText2: ""
    )

//    @State var netomoBranchings: [Branching] = []
//    @State var allScene: Branching = Branching(
//        storyId: "", sceneId: "", sceneType: "",icon: "", characterName: "", leftCharacter: "", rightCharacter: "", text: "",
//        background: "",speechBubble: "", nextSceneId: "", isChoice: nil,
//        choiceText1: "", choiceText2: ""
//    )
//    @State var groupBranchings: [Branching] = []
//    @State var allScene: Branching = Branching(
//        storyId: "", sceneId: "", sceneType: "",icon: "", characterName: "", leftCharacter: "", rightCharacter: "", text: "",
//        background: "",speechBubble: "", nextSceneId: "", isChoice: nil,
//        choiceText1: "", choiceText2: ""
//    )




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
                    MenuView(isOpen: $isMenuOpen)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            /// isMenuOpenの変化にアニメーションをつける
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
                    path.append(ViewBuilderPath.NoteView)
                }

//            csvファイルの読み込み
            .onAppear {
                netomoDialogues = loadCSV(fileName: "netomo_var8_0")
                groupchatDialogues = loadCSV(fileName: "groupchat_var5_0")
                kakusanDialogues = loadCSV(fileName: "kakusan_var5_0")
                let netomoBranchings = loadNetomoBranchingCSV(fileName: "netomo_branch_ver19")
                let groupBranchings = loadNetomoBranchingCSV(fileName: "groupchat_branch_ver4")
                self.allBranchings = netomoBranchings + groupBranchings
//                 print(self.allBranchings.map { $0.storyId })
            }
            .navigationDestination(for: ViewBuilderPath.self) { viewID in
                switch viewID {
                case .ContentView:
                    ContentView()

                case .NoteView:
                    NoteView(path: $path)

                case .StoryBranchView(let StoryId):
                    StoryBranchView(path: $path,
                                    allBranchings: $allBranchings,
                                    allScene: $allScene,
                                    StoryId: StoryId
                    )
                    .navigationBarBackButtonHidden(true)

                case .GroupchatView:
                    GroupchatView(path: $path, groupchatDialogues: $groupchatDialogues)

                case .kakusanView:
                    KakusanView(path: $path, kakusanDialogues: $kakusanDialogues)

                case .NetomoView:
                    NetomoView(netomoDialogues: $netomoDialogues, path: $path)

                }
            }
        }
    }
}

#Preview {
    ContentView()
}
