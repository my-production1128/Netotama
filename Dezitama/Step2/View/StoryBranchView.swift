//
//  NetomoBranchingView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/06/06.
//

import SwiftUI

struct StoryBranchView: View {
    @State private var currentSceneId: String = ""
    @State private var historyStack: [String] = []
    @State private var showSpecialView: Bool = false
    @State private var offsetY: CGFloat = 0.0
    @State var isPopupVisible: Bool = false
    @State var nextChat: Bool = false
    
    
    @State private var displayedText = ""
    @State private var currentCharIndex = 0
    @State private var timer: Timer? = nil
    
    @State private var isTypingComplete: Bool = false
    @State private var shouldSkipTyping: Bool = false
    
    
    // 選択肢のシーンを一時的に保持する新しいState変数
    @State private var currentChoiceScene: Branching? = nil
    
    //    会話の見返しボタン用関数
    @State var isChatLogVisible: Bool = false
    @State private var conversationHistory: [Branching] = []
    
    
    let talkFont = UIFont.customFont(ofSize: 30)
    let charaNameFont = UIFont.customFont(ofSize: 35)
    
    
    
    
    @Binding var path: NavigationPath
    @Binding var allBranchings: [Branching]
    @Binding var allScene: Branching
    
    let StoryId: String
    // 表示に必要なデータだけを、allBranchingsからリアルタイムで絞り込む
    private var currentStoryBranchings: [Branching] {
        return allBranchings.filter { $0.storyId == StoryId }
    }
    
    private var branchingMap: [String: Branching] {
        var map: [String: Branching] = [:]
        for b in currentStoryBranchings {
            if map[b.sceneId] == nil {
                map[b.sceneId] = b
            } else {
                print("⚠️ Duplicate sceneId found in the same story: \(b.sceneId)")
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
                        switch current.sceneType {
                        case "chat":
                            ChatSceneView(
                                branchingMap: branchingMap,
                                initialSceneId: currentSceneId,
                                onNextScene: { nextId in
                                    //                                    print("StoryBranchView: onNextSceneが呼ばれました。nextId = \(nextId)")
                                    historyStack.append(currentSceneId)
                                    currentSceneId = nextId
                                },
                                allBranchings: $allBranchings,
                                allScene: $allScene,
                                isPopupVisible: $isPopupVisible,
                                conversationHistory: $conversationHistory
                            )
                            
                            //                            scenetypeがtalkの
                        case "talk":
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
                                            .frame(height: 450)
                                    }
                                }
                                
                                Group{
                                    //                                     吹き出し背景
                                    Image(current.speechBubble)
                                        .resizable()
                                        .frame(width: 950, height: 250)
                                        .offset(x:-13, y: 0)
                                        .position(x: geometry.size.width * 0.5,y: geometry.size.height * 0.8)
                                    
                                    //                                     キャラ名ラベル
                                    let characterNameText = CharacterName(rawValue: current.characterName)?.displayName ?? current.characterName
                                    
                                    RubyLabelRepresentable(
                                        attributedText: characterNameText
                                            .replacingOccurrences(of: "<br>", with: "\n")
                                            .createRuby(font: charaNameFont, color: .black), // talkFontを使う
                                        font: charaNameFont,
                                        textColor: .black,
                                        textAlignment: .center
                                    )
                                    .font(.system(size: 35))
                                    .font(.title)
                                    .padding(6)
                                    .cornerRadius(8)
                                    .position(x: geometry.size.width * 0.22,y: geometry.size.height * 0.673)

                                    //                                    テキスト（会話文）
                                    TypingRubyLabelRepresentable(
                                        // createWideRuby に font を渡す
                                        attributedText: current.text
                                            .replacingOccurrences(of: "<br>", with: "\n")
                                            .createWideRuby(font: talkFont, color: .black), // ← 修正
                                        charInterval: 0.05,
                                        // こちらにも同じ font を渡す
                                        font: talkFont // ← 修正
                                    )
                                    .fixedSize(horizontal: false, vertical: true) // UILabelのサイズ計算を尊重させる
                                    .frame(maxWidth: 700)
                                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.825)
                                    
                                    //                                     ナビゲーション
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
                                    }
                                }
                                .offset(y: 20)
                            }
                            //                            ↓ここから送信ボタンをタップした時の処理
                            //                            Zstackの範囲を全画面に広げてから.onTapGestureの処理を実行
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // ポップアップ表示中はタップを無効にする
                                if isPopupVisible {
                                    print("ポップアップ表示中のためタップを無効にします。")
                                    return
                                }
                                
                                if let next = branchingMap[current.nextSceneId] {
                                    historyStack.append(currentSceneId)
                                    // 次のシーンが選択肢の場合
                                    if next.isChoice == true {
                                        isPopupVisible = true
                                        currentChoiceScene = next
                                        // ここにprint文を追加
                                        print("次のシーンは選択肢です。isPopupVisible: \(isPopupVisible), choiceSceneId: \(currentChoiceScene?.sceneId ?? "nil")")
                                    } else {
                                        currentSceneId = next.sceneId
                                        print("次のシーンに遷移します。sceneId: \(currentSceneId)")
                                    }
                                    conversationHistory.append(next)
                                }
                            }
                            //                            ↑ここまでonTapGestureの処理
                            
                        default:
                            Text("このscemneTypeは未対応です")
                        }
                        
                        if current.nextSceneId == "end" {
                            Color.black
                                .opacity(0.45)
                                .ignoresSafeArea()
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button {
                                        path.removeLast()
                                    } label: {
                                        Image("back_start")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 500, height: 100)
                                    }
                                }
                            }.padding()
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
                                .padding(.top, 0)
                        }
                        Spacer()
                    }
                }
                
                
                if isPopupVisible, let choiceScene = currentChoiceScene {
                    let _ = print("isChoiceViewを呼び出します。isPopupVisible: \(isPopupVisible), choiceSceneId: \(choiceScene.sceneId)")
                    isChoiceView(
                        isPopupVisible: $isPopupVisible,
                        allScene: .constant(choiceScene),
                        onCorrectChoice: {
                            // 正解した後の次のシーンに遷移するロジック
                            self.currentSceneId = choiceScene.nextSceneId
                            self.currentChoiceScene = nil // ポップアップを非表示にした後、状態をリセット
                        }
                    )
                }
                
                //                会話の見返しボタン
                // ★ 履歴ボタンとログビューの追加
                VStack {
                    HStack {
                        Button(action: {
                            isChatLogVisible.toggle()
                        }) {
                            Image("chat") // chatボタンを流用
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .padding(20)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(2)
                
                if isChatLogVisible {
                    GeometryReader { innerGeometry in
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(conversationHistory, id: \.id) { scene in
                                        let isRight = scene.characterName == scene.rightCharacter
                                        HStack(alignment: .bottom, spacing: 8) {
                                            if !isRight {
                                                Image(scene.icon)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(Circle())
                                            }
                                            
                                            VStack(alignment: isRight ? .trailing : .leading, spacing: 4) {
//                                                見返し用キャラクター名
                                                let characterName = CharacterName(rawValue: scene.characterName)?.displayName ?? "不明"
                                                RubyLabelRepresentable(
                                                    attributedText: characterName
                                                        .replacingOccurrences(of: "<br>", with: "\n")
                                                        .createRuby(font: .customFont(ofSize: 15), color: .black),
                                                    font: .systemFont(ofSize: 15),
                                                    textColor: .black,
                                                    textAlignment: .center
                                                )
                                                .padding(6)
                                                .cornerRadius(8)

                                                //                                                見返し用セリフ
                                                RubyLabelRepresentable(
                                                    attributedText: scene.text
                                                        .replacingOccurrences(of: "<br>", with: "\n")
                                                        .createRuby(font: .customFont(ofSize: 22), color: .black),
                                                    font: .systemFont(ofSize: 20),
                                                    textColor: .black,
                                                    textAlignment: .left
                                                )
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .font(.body)
                                                    .foregroundColor(.black)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .fill(Color.white)
                                                    )
                                            }
                                            .frame(maxWidth: 250, alignment: isRight ? .trailing : .leading)
                                            
                                            if isRight {
                                                Image(scene.icon)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(Circle())
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: isRight ? .trailing : .leading)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 4)
                                        .id(scene.id) // ★ スクロール対象を特定するためIDを付与
                                    }
                                }
                                .padding()
                            }
                            .frame(width: innerGeometry.size.width / 2)
                            .onTapGesture {
                                isChatLogVisible = false
                            }
                            .onChange(of: conversationHistory.count) { // ★ 配列の更新を監視
                                withAnimation {
                                    if let last = conversationHistory.last {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .background(Color.black.opacity(0.6))
                        .edgesIgnoringSafeArea(.all)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                    }
                }
                
                // ... (既存のコード) ...
            }
            .onAppear {
                if let first = currentStoryBranchings.first { // ★ filterされたストーリーの先頭を取得する
                    currentSceneId = first.sceneId
                    startTyping(fullText: first.text)
                    //                    見返し機能用
                    conversationHistory.append(first)
                }
            }
        }
    }
    
    //    三角形アニメーションがループする用の関数
    private func startLoopingAnimation() {
        // 一旦アニメーションをリセット
        offsetY = 0.0
        // 新たにアニメーション
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
