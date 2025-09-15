//
//  NoteView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/27.
//
import SwiftUI

struct NoteView: View {
    @State private var currentImageName: String = "note_gurutama"
    @Binding var path: NavigationPath
    @State private var shakeTrigger: Int = 0
    @State private var showTutorial: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(currentImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: min(geometry.size.width * 1.0, 1150),
                        height: min(geometry.size.height * 1.0, 1000)
                    )
                    .offset(
                        x: geometry.size.width * 0.02
                    )

                // ページ右側の付箋ボタン
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.08)

                    VStack(spacing: geometry.size.height * 0.01) {
                        ForEach(["note_gurutama", "note_netotama", "note_potitama", "note_zukan"], id: \.self) { imageName in
                            Button {
                                currentImageName = imageName
                            } label: {
                                Color.clear.frame(
                                    width: geometry.size.width * 0.08,
                                    height: geometry.size.height * 0.2
                                )
                            }
                        }
                    }
                    .padding(.trailing, geometry.size.width * 0.01)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)

                //<<<<<<< HEAD
                // コンテンツエリア
//                contentView(geometry: geometry)
                //=======
                //                 各ストーリーの詳しい説明のページ
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

                        Button {
                            path.append(ViewBuilderPath.GoodStoryBranchView("groupchat"))
                        } label: {
                            Image("step2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 100)
                        }
                        .offset(x: 280, y: 100)
                    }

                case "note_netotama":
                    ZStack {
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
                            path.append(ViewBuilderPath.GoodStoryBranchView("good_netomo_story1"))
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

                        Button {
                            path.append(ViewBuilderPath.kakusanView)
                        } label: {
                            Image("step1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 100)
                        }
                        .offset(x: 280, y: -180)

                        Button {
                            path.append(ViewBuilderPath.GoodStoryBranchView("kakusan"))
                        } label: {
                            Image("step2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 100)
                        }
                        .offset(x: 280, y: 100)
                    }

                    //図鑑
                default:
                    EmptyView()
                    //>>>>>>> 38bbd39c6aa92ee036c5a0fe414011163876138c
                }
            }
            .background(
                Image("note_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .onAppear {
                let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenTutorial")
                if !hasSeenTutorial {
                    showTutorial = true
                    UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
                }
            }
            .sheet(isPresented: $showTutorial) {
                TutorialView()
            }
        }

        //    @ViewBuilder
        //    private func contentView(geometry: GeometryProxy) -> some View {
        //        switch currentImageName {
        //        case "note_gurutama":
        //            VStack(spacing: geometry.size.height * 0.18) {
        //                Button {
        //                    path.append(ViewBuilderPath.GroupchatView)
        //                } label: {
        //                    Image("step1")
        //                        .resizable()
        //                        .scaledToFit()
        //                        .frame(
        //                            width: geometry.size.width * 0.4,
        //                            height: geometry.size.height * 0.2
        //                        )
        //                }
        //
        //                Button {
        //                    path.append(ViewBuilderPath.StoryBranchView("groupchat"))
        //                } label: {
        //                    Image("step2")
        //                        .resizable()
        //                        .scaledToFit()
        //                        .frame(
        //                            width: geometry.size.width * 0.4,
        //                            height: geometry.size.height * 0.2
        //                        )
        //                }
        //            }
        //            .offset(x: geometry.size.width * 0.23)
        //
        //        case "note_netotama":
        //            VStack(spacing: geometry.size.height * 0.18) {
        //                Button {
        //                    path.append(ViewBuilderPath.NetomoView)
        //                } label: {
        //                    Image("step1")
        //                        .resizable()
        //                        .scaledToFit()
        //                        .frame(
        //                            width: geometry.size.width * 0.4,
        //                            height: geometry.size.height * 0.2
        //                        )
        //                }
        //
        //                Button {
        //                    path.append(ViewBuilderPath.StoryBranchView("netomo"))
        //                } label: {
        //                    Image("step2")
        //                        .resizable()
        //                        .scaledToFit()
        //                        .frame(
        //                            width: geometry.size.width * 0.4,
        //                            height: geometry.size.height * 0.2
        //                        )
        //                }
        //            }
        //            .offset(x: geometry.size.width * 0.23)
        //
        //        case "note_potitama":
        //            VStack(spacing: geometry.size.height * 0.18) {
        //                Button {
        //                    path.append(ViewBuilderPath.kakusanView)
        //                } label: {
        //                    Image("step1")
        //                        .resizable()
        //                        .scaledToFit()
        //                        .frame(
        //                            width: geometry.size.width * 0.4,
        //                            height: geometry.size.height * 0.2
        //                        )
        //                }
        //
        //                Image("step2")
        //                    .resizable()
        //                    .scaledToFit()
        //                    .frame(
        //                        width: geometry.size.width * 0.4,
        //                        height: geometry.size.height * 0.2
        //                    )
        //            }
        //            .offset(x: geometry.size.width * 0.23)
        //
        //        default:
        //            EmptyView()
        //        }
        //    }
    }
}
