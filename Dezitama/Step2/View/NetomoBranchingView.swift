//
//  NetomoBranchingView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/06/06.
//

import SwiftUI
import UIKit

struct NetomoBranchingView: View {
    @State private var currentSceneId: String = ""
    @State private var historyStack: [String] = []
    @State private var showSpecialView: Bool = false
    @State private var offsetY: CGFloat = 0.0
    @State var isPopupVisible: Bool = false
    @State var nextChat: Bool = false


    @State private var displayedText = ""
    @State private var currentCharIndex = 0
    @State private var timer: Timer? = nil




    @Binding var path: NavigationPath
    @Binding var netomoScene: NetomoBranching
    @Binding var netomoBranchings: [NetomoBranching]



    private var branchingMap: [String: NetomoBranching] {
        var map: [String: NetomoBranching] = [:]
        for b in netomoBranchings {
            if map[b.sceneId] == nil {
                map[b.sceneId] = b
            } else {
                print("⚠️ Duplicate sceneId found: \(b.sceneId)")
            }
        }
        return map
    }


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let current = branchingMap[currentSceneId] {
                    VStack {
                        Spacer()
                        //                    scenetypeがchatの時
                        if current.sceneType == "chat" {
                            ChatSceneView(
                                branchingMap: branchingMap,
                                initialSceneId: current.sceneId,
                                onNextScene: { nextId in
                                    historyStack.append(currentSceneId)
                                    currentSceneId = nextId
                                },
                                netomoScene: $netomoScene,
                                netomoBranchings: $netomoBranchings,
                                isPopupVisible: $isPopupVisible
                            )
                        } else {
//                        scenetypeがchatじゃない時
                            ZStack {
                                HStack {
                                    //                                    話し手が1人だった時
                                    if !current.leftCharacter.isEmpty && current.rightCharacter.isEmpty {
                                        Spacer()
                                        Image(current.leftCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 500)
                                            .position(x: geometry.size.width/2,y: geometry.size.height * 0.5)
                                        Spacer()

                                    } else if current.leftCharacter.isEmpty && !current.rightCharacter.isEmpty {
                                        Spacer()

                                        Image(current.rightCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 500)
                                            .position(x: geometry.size.width/2,y: geometry.size.height * 0.5)
                                        Spacer()
                                    } else {
                                        Image(current.leftCharacter)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 450)


                                        Image(current.rightCharacter)
                                            .resizable()
                                            .scaledToFit()
                                        //                                                .renderingMode(.template)
//                                            .grayscale(0.5)
                                            .frame(height: 450)
                                        //                                                .foregroundStyle(Color.gray)
                                    }
                                }

                                Group{
                                    // 吹き出し背景
                                    Image(current.speechBubble)
                                        .resizable()
                                        .frame(width: 950, height: 250)
                                        .offset(x:-13, y: 0)
                                        .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.8)

                                    // キャラ名ラベル
                                    Text(current.characterName)
                                        .font(.system(size: 35))
                                        .font(.title)
                                        .padding(6)
                                        .cornerRadius(8)
                                        .position(x: geometry.size.width * 0.22,y: geometry.size.height * 0.685)

//                                    セリフ本文
//                                    チャット以外専用のルビつきのテキスト
//                                    WideRubyLabelRepresentable(
//                                        attributedText: (current.text.replacingOccurrences(of: "<br>", with: "\n").createRuby()),
//                                        font: .systemFont(ofSize: 30),
//                                        textColor: .black,
//                                        textAlignment: .left
//                                    )
//                                    .frame(width: 700, height: 500)
//                                    .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.825)

//                                    WideRubyLabelRepresentable(
//                                        attributedText: (displayedText.replacingOccurrences(of: "<br>", with: "\n").createRuby()),
//                                        font: .systemFont(ofSize: 30),
//                                        textColor: .black,
//                                        textAlignment: .left
//                                    )
//                                    .frame(width: 700, height: 500)
//                                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)
//                                    .onChange(of: currentSceneId) {
//                                        if let newScene = branchingMap[currentSceneId] {
//                                            startTyping(fullText: newScene.text)
//                                        }
//                                    }

                                    TypingRubyLabelRepresentable(
                                        attributedText: current.text.replacingOccurrences(of: "<br>", with: "\n").createRuby(),
                                        charInterval: 0.05,
                                        font: .systemFont(ofSize: 30)
                                    )
                                    .frame(width: 700, height: 500)
                                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)





                                    // ナビゲーション
                                    HStack {
                                        Image("next_button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 35)
                                            .position(x: geometry.size.width * 0.85,y: geometry.size.height * 0.905)
                                            .offset(y: offsetY)
                                            .onAppear {
                                                startLoopingAnimation()
                                            }
                                            .onTapGesture {
                                                if let next = branchingMap[current.nextSceneId] {
                                                    historyStack.append(currentSceneId)
                                                    currentSceneId = next.sceneId
                                                }
                                            }
//                                            .contentShape(Rectangle())
                                            .expandedTapArea(20)
                                    }
                                }
                            }
                        }
                    }
                    .background {
                        Image(current.background)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    }
                    .ignoresSafeArea()
                } else {
                    Text("ストーリーが読み込めませんでしたnetomoBranchView")
                }

                HStack {
                    Spacer()
                    VStack {
                        Button {
                            path.removeLast()
                        }label: {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(.top, 30)
                            //                        .overlay{
                            //                            // isGrayOutがtrueの時にグレーアウト
                            //                            Color.black.opacity(isPopupVisible ? 0.45 : 0)
                            //                        }
                        }
                        Spacer()
                    }
                }
            }
            .onAppear {
                if let first = netomoBranchings.first {
                    currentSceneId = first.sceneId
                    startTyping(fullText: first.text)
                }
            }
        }
    }

    //    三角形アニメーションがループする用の関数
    private func startLoopingAnimation() {
        let animation = Animation
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)

        withAnimation(animation) {
            offsetY = 8.0
        }
    }

    func startTyping(fullText: String) {
        displayedText = ""
        currentCharIndex = 0
        timer?.invalidate()
        

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            if currentCharIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentCharIndex)
                displayedText.append(fullText[index])
                currentCharIndex += 1
            } else {
                t.invalidate()
                timer = nil
            }
        }
    }
}


extension View {
    /// 見た目を変えずにタップ領域だけ広げる
    func expandedTapArea(_ size: CGFloat) -> some View {
        self
            // 1) size 分だけ余分に padding を足して…
            .padding(size)
            // 2) その余分な部分も含めてタップ可能にし…
            .contentShape(Rectangle())
            // 3) レイアウト上は元に戻す
            .padding(-size)
    }
}
