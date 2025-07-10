//
//  NetomoView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/06.
//

import SwiftUI

struct NetomoView: View {
    // ContentViewでロードしたCSVファイルをバインド
    @Binding var netomoDialogues: [Dialogue]
    @State private var currentIndex = 0
    @State private var isShowingLog = false
    @State private var goChoiceView = false

    @Binding var path: NavigationPath

    var body: some View {
        Group {
            if currentIndex < netomoDialogues.count {
                let _ = print(netomoDialogues.count)
                sceneView(for: netomoDialogues[currentIndex])
            } else {
                let _ = print(netomoDialogues.count)
                // 終了画面やChoiceViewへの遷移
                ZStack {
                    Image("sky")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    HStack {
                        Spacer()
                        Button(action: {
                            //                        goChoiceView = true
                            path.removeLast()
                        }) {
                            Image("story_back")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
//                                .padding()
                        }
//                        .offset(x: 400)
                    }
                }
//                .navigationDestination(isPresented: $goChoiceView) {
//                    ChoiceView(path: $path,
//                               netomoScene: $netomoScene,
//                               netomoBranchings: $netomoBranchings)
//                }
            }
        }
    }

    
    @ViewBuilder
    func sceneView(for current: Dialogue) -> some View {
        switch current.background {
        case "Introduction" :
            ZStack{
                //背景
                Image("netotama_blackboard")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .onTapGesture {
                currentIndex += 1
            }
            
        case "Chat1" :
            ZStack{
                //背景
                Image("chat_netotama")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                //テキスト
                ZStack(alignment: .bottom) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(0...currentIndex, id: \.self) { index in
                                    let dialogue = netomoDialogues[index]
                                    let isRight = dialogue.characterName == "カール"
                                    
                                    HStack(alignment: .bottom) {
                                        if isRight { Spacer() }
                                        
                                        if !isRight {
                                            Image("nick_icon")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .padding(.leading, 8)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(dialogue.characterName)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                            
                                            Text(dialogue.dialogueText)
                                                .padding()
                                                .font(.title3)
                                                .foregroundColor(.black)
                                                .background(Color.white.opacity(0.8))
                                                .cornerRadius(20)
                                        }
                                        .frame(maxWidth: 200, alignment: isRight ? .trailing : .leading)
                                        .padding(isRight ? .trailing : .leading, 0)
                                        
                                        
                                        if isRight {
                                            Image("curl_icon")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .padding(.trailing, 8)
                                        }
                                        
                                        if !isRight { Spacer() }
                                    }
                                    .id(index)
                                }
                            }
                            .padding(.bottom, 80)
                            .padding(.top)
                        }
                        .frame(width: 450, height: 400)
                        .offset(y:-60)
                        .onChange(of: currentIndex) {
                            withAnimation {
                                proxy.scrollTo(currentIndex, anchor: .bottom)
                            }
                        }
                    }
                    
                    //ボタン
                    Button(action: {
                        currentIndex += 1
                    }) {
                        Image("soushin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding()
                    }
                    .offset(x:175,y:115)
                }
            }
            
        case "Park" :
            ZStack{
                //背景
                Image("park")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                //キャラクター
                if current.characterName == "ニック" {
                    HStack{
                        Image("ニック")
                            .resizable()
                            .frame(width: 300, height: 700)
                        Image("サンドラ")
                            .resizable()
                            .frame(width: 400, height: 400)
                        
                    }
                } else {
                    HStack{
                        Image("ニック")
                            .resizable()
                            .frame(width: 250, height: 650)
                        Image("サンドラ")
                            .resizable()
                            .frame(width: 450, height: 450)
                        
                    }
                }
                //吹き出し
                Image("speech_bubble_yellow")
                    .resizable()
                    .frame(width: 900, height: 250)
                    .offset(x: 0, y:200)
                
                //名前
                Text(current.characterName)
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .offset(x:-300, y:90)
                
                //テキスト
                Text(current.dialogueText)
                    .font(.largeTitle)
                    .frame(width: 600, height: 300)
                    .multilineTextAlignment(.center)
                    .cornerRadius(12)
                    .offset(y:200)
                
                //ボタン
                Button(action: {
                    currentIndex += 1
                }) {
                    Image("next_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                .offset(x:400,y:300)
                
                //セリフボタン
                Button(action: {
                    isShowingLog.toggle()
                }) {
                    Image("soushin")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                }
                .offset(x: -480, y: -350)
                .zIndex(2)
                
                if isShowingLog {
                    GeometryReader { geometry in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(0...currentIndex, id: \.self) { index in
                                    let dialogue = netomoDialogues[index]
                                    let isRight = dialogue.characterName == "サンドラ"
                                    
                                    HStack(alignment: .bottom) {
                                        if isRight { Spacer() }
                                        
                                        if !isRight {
                                            Image("nick_icon")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .padding(.leading, 8)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(dialogue.characterName)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                            
                                            Text(dialogue.dialogueText)
                                                .padding()
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .background(isRight ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
                                                .cornerRadius(20)
                                        }
                                        .frame(maxWidth: 200, alignment: isRight ? .trailing : .leading)
                                        .padding(isRight ? .trailing : .leading, 0)
                                        
                                        
                                        if isRight {
                                            Image("sandra_icon")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .padding(.trailing, 8)
                                        }
                                        
                                        if !isRight { Spacer() }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(16)
                        .frame(width: geometry.size.width / 2, height: geometry.size.height)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                    }
                }
            }
            
        case "Chat2" :
            ZStack{
                //背景
                Image("chat_netotama")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                //テキスト
                ZStack(alignment: .bottom) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(0...currentIndex, id: \.self) { index in
                                    let dialogue = netomoDialogues[index]
                                    let isRight = dialogue.characterName == "サンドラ"
                                    
                                    HStack(alignment: .bottom) {
                                        if isRight { Spacer() }
                                        
                                        if !isRight {
                                            Image("sandra_icon")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .padding(.leading, 8)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(dialogue.characterName)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                            
                                            Text(dialogue.dialogueText)
                                                .padding()
                                                .font(.title3)
                                                .foregroundColor(.black)
                                                .background(Color.white.opacity(0.8))
                                                .cornerRadius(20)
                                        }
                                        .frame(maxWidth: 200, alignment: isRight ? .trailing : .leading)
                                        .padding(isRight ? .trailing : .leading, 0)
                                        
                                        
                                        if isRight {
                                            Image("nick_icon")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .padding(.trailing, 8)
                                        }
                                        
                                        if !isRight { Spacer() }
                                    }
                                    .id(index)
                                }
                            }
                            .padding(.bottom, 80)
                            .padding(.top)
                        }
                        .frame(width: 450, height: 400)
                        .offset(y:-60)
                        .onChange(of: currentIndex) {
                            withAnimation {
                                proxy.scrollTo(currentIndex, anchor: .bottom)
                            }
                        }
                    }
                    
                    //ボタン
                    Button(action: {
                        currentIndex += 1
                    }) {
                        Image("soushin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding()
                    }
                    .offset(x:175,y:115)
                }
            }
            
        case "News" :
            ZStack{
                //背景
                Image("news")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                //吹き出し
                Image("speech_bubble_blue")
                    .resizable()
                    .frame(width: 900, height: 250)
                    .offset(x: 0, y:200)
                
                //名前
                Text(current.characterName)
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .offset(x:-300, y:90)
                
                //テキスト
                Text(current.dialogueText)
                    .font(.largeTitle)
                    .frame(width: 600, height: 300)
                    .multilineTextAlignment(.center)
                    .cornerRadius(12)
                    .offset(y:200)
                
                //ボタン
                Button(action: {
                    currentIndex += 1
                }) {
                    Image("next_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                .offset(x:400,y:300)
            }
            
        default:
            ZStack {
                Image("sky")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                Text(current.dialogueText)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .cornerRadius(12)
                    .padding()
                    .contentShape(Rectangle())
                
                if currentIndex >= netomoDialogues.count - 1 {
                    Button(action: {
                        goChoiceView = true
                    }) {
                        Image("story_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .padding()
                    }
                    .offset(x: 400, y: 300)
                }
            }
            .onTapGesture {
                if currentIndex < netomoDialogues.count - 1 {
                    currentIndex += 1
                }
            }
//            .navigationDestination(isPresented: $goChoiceView) {
//                ChoiceView()
//            }
        }
    }
}
