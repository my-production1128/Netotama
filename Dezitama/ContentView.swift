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




    @State private var path = NavigationPath()
    @State private var isTextVisible: Bool = false// テキストの点滅
    @State var netomoBranchings: [Branching] = []
    @State var netomoScene: Branching = Branching(
        storyId: "", sceneId: "", sceneType: "",icon: "", characterName: "", leftCharacter: "", rightCharacter: "", text: "",
        background: "",speechBubble: "", nextSceneId: "", isChoice: nil,
        choiceText1: "", choiceText2: ""
    )
    @State var groupchatBranchings: [Branching] = []
    @State var gropchatScene: Branching = Branching(
        storyId: "", sceneId: "", sceneType: "",icon: "", characterName: "", leftCharacter: "", rightCharacter: "", text: "",
        background: "",speechBubble: "", nextSceneId: "", isChoice: nil,
        choiceText1: "", choiceText2: ""
    )


    var body: some View {
        NavigationStack(path: $path) {
                ZStack{
                    Color(red: 0.68, green: 0.93, blue: 0.93)
                        .ignoresSafeArea()
                VStack {
                    Spacer()

                    Button {
                        path.append(ViewBuilderPath.ChoiceView)
                    } label: {
                        Text("Tap to Start")
                    }

                    Spacer()
                }
            }
//            csvファイルの読み込み
            .onAppear {
                netomoDialogues = loadCSV(fileName: "netomo_var8_0")
                groupchatDialogues = loadCSV(fileName: "groupchat_var5_0")
                kakusanDialogues = loadCSV(fileName: "kakusan_var5_0")
                netomoBranchings = loadNetomoBranchingCSV(fileName: "netomo_branch_ver19")//ネトモの分岐ありのストーリー
                groupchatBranchings = loadNetomoBranchingCSV(fileName: "gruopchat_branch_ver1")

            }
            .navigationDestination(for: ViewBuilderPath.self) { viewID in
                switch viewID {
                case .ContentView:
                    ContentView()

                case .ChoiceView:
                    ChoiceView(path: $path,
                               netomoScene: $netomoScene,
                               netomoBranchings: $netomoBranchings)

                case .NetomoBranchingView:
                    NetomoBranchingView(path: $path,
                                             netomoScene: $netomoScene,
                                             netomoBranchings: $netomoBranchings)
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
