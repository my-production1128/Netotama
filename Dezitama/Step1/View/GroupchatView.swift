//
//  DialogueView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//

import SwiftUI

struct GroupchatView: View {
//    @Binding var groupchatDialogues: [Dialogue]
    @State private var currentIndex = 0
    @State private var isShowingLog = false
    @State private var goChoiceView = false

    @Binding var path: NavigationPath
    @Binding var groupchatDialogues: [Dialogue]
//    @Binding var netomoScene: NetomoBranching
//    @Binding var netomoBranchings: [NetomoBranching]

    var body: some View {
        Group {
            if currentIndex < groupchatDialogues.count {
                sceneView(for: groupchatDialogues[currentIndex])
            } else {
                // 終了画面やChoiceViewへの遷移
                ZStack {
                    Image("sky")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

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
        }
    }
    
    @ViewBuilder
    func sceneView(for current: Dialogue) -> some View {
        switch current.background {
        case "Introduction" :
            ZStack{
                //背景
                Image("gurutama_blackboard")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .onTapGesture {
                currentIndex += 1
            }
            
        //教室１
        case "Classroom1" :
            ZStack{
                //背景
                Image("classroom")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                //キャラクター
                ZStack{
                    if current.characterName == "アレック" {
                        Image("アレック")
                            .resizable()
                            .frame(width: 300, height: 700)
                            .offset(x:-300)
                        Image("セシル")
                            .resizable()
                            .frame(width: 250, height: 450)
                            .offset(x:0)
                        Image("コニー")
                            .resizable()
                            .frame(width: 250, height: 450)
                            .offset(x:300)
                        
                    } else if current.characterName == "セシル" {
                            Image("アレック")
                                .resizable()
                                .frame(width: 250, height: 650)
                                .offset(x:-300)
                            Image("セシル")
                                .resizable()
                                .frame(width: 300, height: 500)
                                .offset(x:0)
                            Image("コニー")
                                .resizable()
                                .frame(width: 250, height: 450)
                                .offset(x:300)
                        
                    } else {
                            Image("アレック")
                                .resizable()
                                .frame(width: 250, height: 650)
                                .offset(x:-300)
                            Image("セシル")
                                .resizable()
                                .frame(width: 250, height: 450)
                                .offset(x:0)
                            Image("コニー")
                                .resizable()
                                .frame(width: 300, height: 500)
                                .offset(x:300)
                    }
                }
                //吹き出し
                Image("speech_bubble_yellow")
                    .resizable()
                    .frame(width: 1000, height: 300)
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
            
        //チャット画面１
        case "Chat1" :
            ZStack{
                //背景
                Image("chat_gurutama")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                //テキスト
                ZStack(alignment: .bottom) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(0...currentIndex, id: \.self) { index in
                                    let dialogue = groupchatDialogues[index]
                                    let isRight = dialogue.characterName == "セシル"

                                    HStack(alignment: .bottom) {
                                        if isRight { Spacer() }
                                        
                                        if !isRight {
                                            Image("alex_icon")
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
                                            Image("cecil_icon")
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
            
        //教室２
        case "Classroom2" :
                ZStack{
                    //背景
                    Image("classroom")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    //キャラクター
                    ZStack {
                        if current.characterName == "アレック" {
                            Image("アレック")
                                .resizable()
                                .frame(width: 300, height: 700)
                                .offset(x: -150)
                            
                            Image("セシル")
                                .resizable()
                                .frame(width: 250, height: 450)
                                .offset(x: 50)
                            
                            Image("コニー")
                                .resizable()
                                .frame(width: 250, height: 450)
                                .offset(x: 180)
                        } else if current.characterName == "セシル" {
                            HStack{
                                Image("アレック")
                                    .resizable()
                                    .frame(width: 250, height: 650)
                                    .offset(x:-150)
                                Image("セシル")
                                    .resizable()
                                    .frame(width: 300, height: 500)
                                    .offset(x:0)
                                Image("コニー")
                                    .resizable()
                                    .frame(width: 250, height: 450)
                                    .offset(x:150)
                            }
                        } else if current.characterName == "コニー" {
                            HStack{
                                Image("アレック")
                                    .resizable()
                                    .frame(width: 250, height: 650)
                                    .offset(x:-150)
                                Image("セシル")
                                    .resizable()
                                    .frame(width: 250, height: 450)
                                    .offset(x:0)
                                Image("コニー")
                                    .resizable()
                                    .frame(width: 300, height: 500)
                                    .offset(x:150)
                            }
                        }
                        else if current.characterName == "カール" {
                            HStack{
                                Image("カール")
                                    .resizable()
                                    .frame(width: 300, height: 600)
                                Image("先生")
                                    .resizable()
                                    .frame(width: 300, height: 450)
                            }
                        }
                        else {
                            HStack{
                                Image("カール")
                                    .resizable()
                                    .frame(width: 250, height: 550)
                                Image("先生")
                                    .resizable()
                                    .frame(width: 350, height: 500)
                            }
                        }
                    }
                    
                    //吹き出し
                    Image("speech_bubble_yellow")
                        .resizable()
                        .frame(width: 1000, height: 300)
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
            
        //チャット画面２
        case "Chat2" :
            ZStack{
                //背景
                Image("chat_gurutama")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                //テキスト
                ZStack(alignment: .bottom) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(0...currentIndex, id: \.self) { index in
                                    let dialogue = groupchatDialogues[index]
                                    let isRight = dialogue.characterName == "セシル"

                                    HStack(alignment: .bottom) {
                                        if isRight { Spacer() }
                                        
                                        if !isRight {
                                            Image("alex_icon")
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
                                            Image("cecil_icon")
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
            
        //教室３
        case "Classroom3" :
            ZStack{
                //背景
                Image("classroom")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                //キャラクター
                if current.characterName == "アレック" {
                    HStack{
                        Image("アレック")
                            .resizable()
                            .frame(width: 300, height: 700)
                        Image("セシル")
                            .resizable()
                            .frame(width: 250, height: 450)
                        Image("コニー")
                            .resizable()
                            .frame(width: 250, height: 450)
                    }
                } else if current.characterName == "セシル" {
                    HStack{
                        Image("アレック")
                            .resizable()
                            .frame(width: 250, height: 650)
                        Image("セシル")
                            .resizable()
                            .frame(width: 300, height: 500)
                        Image("コニー")
                            .resizable()
                            .frame(width: 250, height: 450)
                    }
                } else if current.characterName == "コニー" {
                    HStack{
                        Image("アレック")
                            .resizable()
                            .frame(width: 250, height: 650)
                        Image("セシル")
                            .resizable()
                            .frame(width: 250, height: 450)
                        Image("コニー")
                            .resizable()
                            .frame(width: 300, height: 500)
                    }
                }
                else if current.characterName == "ブライアン" {
                    HStack{
                        Image("ブライアン")
                            .resizable()
                            .frame(width: 350, height: 500)
                        Image("カール")
                            .resizable()
                            .frame(width: 250, height: 550)
                    }
                }
                else if current.characterName == "カール" {
                    HStack{
                        Image("ブライアン")
                            .resizable()
                            .frame(width: 300, height: 450)
                        Image("カール")
                            .resizable()
                            .frame(width: 300, height: 600)
                    }
                }
                else {
                    HStack{
                        Image("先生")
                            .resizable()
                            .frame(width: 350, height: 500)
                    }
                }
                
                //吹き出し
                Image("speech_bubble_yellow")
                    .resizable()
                    .frame(width: 1000, height: 300)
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
            
        //チャット画面３
        case "Chat3" :
            ZStack{
                //背景
                Image("chat_gurutama")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                //テキスト
                ZStack(alignment: .bottom) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(0...currentIndex, id: \.self) { index in
                                    let dialogue = groupchatDialogues[index]
                                    let isRight = dialogue.characterName == "セシル"

                                    HStack(alignment: .bottom) {
                                        if isRight { Spacer() }

                                        if !isRight {
                                            Image("alex_icon")
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
                                            Image("cecil_icon")
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
            
            
        //その他
        default:
            ZStack {
                // 背景
                Image("sky")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // テキスト
                Text(current.dialogueText)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .cornerRadius(12)
                    .padding()
                    .contentShape(Rectangle())
                
                
            }
            .onTapGesture {
                if currentIndex < groupchatDialogues.count - 1 {
                    currentIndex += 1
                }
            }
        }
    }
}
