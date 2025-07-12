//
//  ChoiceView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/27.
//

//.border(Color.black, width: 5)



import SwiftUI

struct ChoiceView: View {
//    @State private var netomoArray: [Dialogue] = []
//    @State private var groupchatArray: [Dialogue] = []
//    @State private var kakusanArray: [Dialogue] = []
    @State private var currentImageName: String = "note_gurutama"

    @Binding var path: NavigationPath
    @Binding var netomoScene: NetomoBranching
    @Binding var netomoBranchings: [NetomoBranching]


    var body: some View {
//        NavigationStack {
            ZStack {
                // 背景ノート画像
                Image(currentImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 850, height: 750)
                    .offset(x: 20, y: -20)
                
                // ページ右側の付箋でも切り替えボタン
                VStack {
                    Spacer()
                        .frame(height: 20)
                    VStack {
                        Button {
                            currentImageName = "note_gurutama"
                        } label: {
                            Color.clear.frame(width: 70, height: 160)
                        }
                        
                        Button {
                            currentImageName = "note_netotama"
                        } label: {
                            Color.clear.frame(width: 70, height: 160)
                        }
                        
                        Button {
                            currentImageName = "note_potitama"
                        } label: {
                            Color.clear.frame(width: 70, height: 150)
                        }
                        
                        Button {
                            currentImageName = "note_zukan"
                        } label: {
                            Color.clear.frame(width: 70, height: 150)
                        }
                    }
                    .padding(.trailing, 5)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                
                // 各ストーリーの詳しい説明のページ
                switch currentImageName {
                case "note_gurutama":
                    ZStack {

                        Button {
                            path.append(ViewBuilderPath.GroupchatView)
                        } label: {
                            Image("step1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 100)
                        }
                        .offset(x: 280, y: -180)

                        Image("step2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 100)
                            .offset(x: 280, y: 100)
                    }
                    
                case "note_netotama":
                    ZStack {
//                        NavigationLink(destination: NetomoView(dialogues: netomoArray)) {
//                            Image("step1")
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 250, height: 100)
//                        }
//                        .offset(x: 280, y: -180)
//                        ネトモ・ステップ１
                        Button {
                            path.append(ViewBuilderPath.NetomoView)
                        } label: {
                            Image("step1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 100)
                        }
                        .offset(x: 280, y: -180)

//                        ネトモ・ステップ２
                        Button {
                            path.append(ViewBuilderPath.NetomoBranchingView)
                        } label: {
                            Image("step2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 100)
                        }
                        .offset(x: 280, y: 100)
                    }
                    
                case "note_potitama":
                    ZStack {
//                        NavigationLink(destination: KakusanView(dialogues: kakusanArray)) {
//                            Image("step1")
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 250, height: 100)
//                        }
//                        .offset(x: 280, y: -180)

                        Button {
                            path.append(ViewBuilderPath.kakusanView)
                        } label: {
                            Image("step1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 100)
                        }
                        .offset(x: 280, y: -180)

                        Image("step2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 100)
                            .offset(x: 280, y: 100)
                    }
                
                    //図鑑
                default:
                    EmptyView()
                }
            }
//            .onAppear {
//                netomoArray = loadCSV(fileName: "netomo_var8_0")
//                groupchatArray = loadCSV(fileName: "groupchat_var5_0")
//                kakusanArray = loadCSV(fileName: "kakusan_var5_0")
//                netomoBranchings = loadNetomoBranchingCSV(fileName: "netomo_branch_ver11")//ネトモの分岐ありのストーリー
//                
//            }
//        }
    }
}
