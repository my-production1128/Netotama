//
//  KakusanView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/06.
//

import SwiftUI

struct KakusanView: View {
//    let dialogues: [Dialogue]
//    @State var dialogues: [Dialogue] = []
    @State private var currentIndex = 0
    @State private var isShowingLog = false
    
    @Binding var path: NavigationPath
    @Binding var kakusanDialogues: [Dialogue]

    var body: some View {
        let current = kakusanDialogues[currentIndex]
//        let current = dialogues

        //導入
        if current.background == "Introduction" {
            ZStack{
                //背景
                Image("potitama_blackboard")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .onTapGesture {
                currentIndex += 1
            }

        //公園
        }else if current.background == "Park" {
            ZStack{
                //背景
                Image("park")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                //キャラクター
                if current.characterName == "コニー" {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 400, height: 600)
                        Image("セシル")
                            .resizable()
                            .frame(width: 350, height: 550)

                    }
                } else {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 350, height: 550)
                        Image("セシル")
                            .resizable()
                            .frame(width: 400, height: 600)

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
            }

        //逆上がり動画
        } else if current.background == "Move1" {
            ZStack{
                Image("sky")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .onTapGesture {
                currentIndex += 1
            }

        //チャット１
        } else if current.background == "Chat1" {
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
                                    let dialogue = kakusanDialogues[index]
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
                                                .foregroundColor(.black)
                                                .background(Color.white.opacity(0.8))
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

        //Chat画面２
        } else if current.background == "Chat2" {
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
                                    let dialogue = kakusanDialogues[index]
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
                                                .foregroundColor(.black)
                                                .background(Color.white.opacity(0.8))
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

        //教室１
        } else if current.background == "Classroom1" {
            ZStack{
                //背景
                Image("park")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                //キャラクター
                if current.characterName == "コニー" {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 400, height: 600)
                        Image("セシル")
                            .resizable()
                            .frame(width: 350, height: 550)

                    }
                } else {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 350, height: 550)
                        Image("セシル")
                            .resizable()
                            .frame(width: 400, height: 600)

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
            }

        //コニーの家
        } else if current.background == "Cony" {
            ZStack{
                //背景
                Image("park")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                //キャラクター
                if current.characterName == "コニー" {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 400, height: 600)
                        Image("セシル")
                            .resizable()
                            .frame(width: 350, height: 550)

                    }
                } else {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 350, height: 550)
                        Image("セシル")
                            .resizable()
                            .frame(width: 400, height: 600)

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
            }

        //教室２
        } else if current.background == "Classroom2" {
            ZStack{
                //背景
                Image("park")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                //キャラクター
                if current.characterName == "コニー" {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 400, height: 600)
                        Image("セシル")
                            .resizable()
                            .frame(width: 350, height: 550)

                    }
                } else {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 350, height: 550)
                        Image("セシル")
                            .resizable()
                            .frame(width: 400, height: 600)

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
            }

        //教室３
        } else if current.background == "Classroom3" {
            ZStack{
                //背景
                Image("park")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                //キャラクター
                if current.characterName == "コニー" {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 400, height: 600)
                        Image("セシル")
                            .resizable()
                            .frame(width: 350, height: 550)

                    }
                } else {
                    HStack{
                        Image("コニー")
                            .resizable()
                            .frame(width: 350, height: 550)
                        Image("セシル")
                            .resizable()
                            .frame(width: 400, height: 600)

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
            }
        } else {
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

                if currentIndex >= kakusanDialogues.count - 1 {
                    Button(action: {
                        path.removeLast()
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
                if currentIndex < kakusanDialogues.count - 1 {
                    currentIndex += 1
                }
            }
        }
    }
}
