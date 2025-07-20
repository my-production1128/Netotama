//
//  NoteView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/27.
//
import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10   // 揺れる振幅
    var shakesPerUnit: CGFloat = 3  // 揺れる回数（1ユニットでこの回数）
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

struct NoteView: View {
    @State private var currentImageName: String = "note_gurutama"

    @Binding var path: NavigationPath
//    @Binding var allBranchings: [Branching]
//    @Binding var allScene: Branching

//    @Binding var netomoScene: Branching
//    @Binding var netomoBranchings: [Branching]
//    @Binding var groupScene: Branching
//    @Binding var groupBranchings: [Branching]

    @State private var shakeTrigger: Int = 0
    @State private var showTutorial: Bool = true

    var body: some View {
        ZStack {
            //                 背景ノート画像
            Image(currentImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 850, height: 750)
                .offset(x: 20, y: -20)

//                 ページ右側の付箋でも切り替えボタン
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
                        path.append(ViewBuilderPath.StoryBranchView("groupchat"))
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
                        path.append(ViewBuilderPath.StoryBranchView("netomo"))
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
        .background(Image("note_background")
            .resizable()
            .scaledToFill())
    }
}
