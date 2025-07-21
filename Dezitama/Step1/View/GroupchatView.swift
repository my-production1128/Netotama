//
//  DialogueView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//

import SwiftUI

struct GroupchatView: View {
    @State private var currentIndex = 0
    @State private var isShowingLog = false
    @State private var goChoiceView = false

    @Binding var path: NavigationPath
    @Binding var groupchatDialogues: [Dialogue]

    var body: some View {
        Group {
            if currentIndex < groupchatDialogues.count {
                sceneView(for: groupchatDialogues[currentIndex])
            } else {
                // 終了画面やNoteViewへの遷移
                ZStack {
                    Image("sky")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()


//                    選択画面に戻る
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
                        Image("Alec")
                            .resizable()
                            .frame(width: 300, height: 700)
                            .offset(x:-300)
                        Image("Cecil")
                            .resizable()
                            .frame(width: 250, height: 450)
                            .offset(x:0)
                        Image("Cony")
                            .resizable()
                            .frame(width: 250, height: 450)
                            .offset(x:300)

                    } else if current.characterName == "セシル" {
                        Image("Alec")
                            .resizable()
                            .frame(width: 250, height: 650)
                            .offset(x:-300)
                        Image("Cecil")
                            .resizable()
                            .frame(width: 300, height: 500)
                            .offset(x:0)
                        Image("Cony")
                            .resizable()
                            .frame(width: 250, height: 450)
                            .offset(x:300)

                    } else {
                        Image("Alec")
                            .resizable()
                            .frame(width: 250, height: 650)
                            .offset(x:-300)
                        Image("Cecil")
                            .resizable()
                            .frame(width: 250, height: 450)
                            .offset(x:0)
                        Image("Cony")
                            .resizable()
                            .frame(width: 300, height: 500)
                            .offset(x:300)
                    }
                }
                //吹き出し
                Image("speech_bubble_beige")
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

                //戻るボタン
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

                        }
                        Spacer()
                    }
                }
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
                                ForEach(15...currentIndex, id: \.self) { index in
                                    let dialogue = groupchatDialogues[index]
                                    let isRight = dialogue.characterName == "セシル"

                                    HStack(alignment: .bottom, spacing: 8) {
                                        if isRight {
                                            Spacer()
                                        }

                                        if !isRight {
                                            // 左側キャラのアイコン（アレックとコニー）
                                            Image(getCharacterIcon(for: dialogue.characterName))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }

                                        VStack(alignment: isRight ? .trailing : .leading, spacing: 4) {
                                            // キャラクター名
                                            Text(dialogue.characterName)
                                                .font(.caption)
                                                .foregroundColor(.secondary)

                                            // セリフ
                                            Text(dialogue.dialogueText)
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
                                            // 右側キャラのアイコン（セシル）
                                            Image("cecil_icon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }

                                        if !isRight {
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
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

                //戻るボタン
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

                        }
                        Spacer()
                    }
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
                            Image("Alec")
                                .resizable()
                                .frame(width: 300, height: 700)
                                .offset(x:-300)
                            Image("Cecil")
                                .resizable()
                                .frame(width: 250, height: 450)
                                .offset(x:0)
                            Image("Cony")
                                .resizable()
                                .frame(width: 250, height: 450)
                                .offset(x:300)

                        } else if current.characterName == "セシル" {
                                Image("Alec")
                                    .resizable()
                                    .frame(width: 250, height: 650)
                                    .offset(x:-300)
                                Image("Cecil")
                                    .resizable()
                                    .frame(width: 300, height: 500)
                                    .offset(x:0)
                                Image("Cony")
                                    .resizable()
                                    .frame(width: 250, height: 450)
                                    .offset(x:300)

                        } else if current.characterName == "コニー" {
                                Image("Alec")
                                    .resizable()
                                    .frame(width: 250, height: 650)
                                    .offset(x:-300)
                                Image("Cecil")
                                    .resizable()
                                    .frame(width: 250, height: 450)
                                    .offset(x:0)
                                Image("Cony")
                                    .resizable()
                                    .frame(width: 300, height: 500)
                                    .offset(x:300)
                        }
                        else if current.characterName == "カール" {
                            HStack{
                                Image("Curl")
                                    .resizable()
                                    .frame(width: 300, height: 600)
                                    .offset(x:-100)
                                Image("Teacher")
                                    .resizable()
                                    .frame(width: 300, height: 450)
                                    .offset(x:100)
                            }
                        }
                        else {
                            HStack{
                                Image("Curl")
                                    .resizable()
                                    .frame(width: 250, height: 550)
                                    .offset(x:-100)
                                Image("Teacher")
                                    .resizable()
                                    .frame(width: 350, height: 500)
                                    .offset(x:100)
                            }
                        }
                    }

                    //吹き出し
                    Image("speech_bubble_beige")
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

                    //戻るボタン
                    HStack{
                        Spacer()
                        VStack{
                            Button(action: {
                                path.removeLast()
                            }) {
                                Image("home")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .padding(.top, 30)
                            }
                            Spacer()
                        }
                    }

                    //セリフボタン
                    HStack {
                        VStack {
                            Button(action: {
                                isShowingLog.toggle()
                            }) {
                                Image("chat")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                            }
//                            .frame(width: 50, height: 50) // タッチエリアを制限

                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(50)
                    .zIndex(2)

                    if isShowingLog {
                        GeometryReader { geometry in
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(1...currentIndex, id: \.self) { index in
                                        let dialogue = groupchatDialogues[index]
                                        let isRight = dialogue.characterName == "セシル"

                                        HStack(alignment: .bottom, spacing: 8) {
                                            if isRight {
                                                Spacer()
                                            }

                                            if !isRight {
                                                // 左側キャラのアイコン（アレックとコニー）
                                                Image(getCharacterIcon(for: dialogue.characterName))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(Circle())
                                            }

                                            VStack(alignment: isRight ? .trailing : .leading, spacing: 4) {
                                                // キャラクター名
                                                Text(dialogue.characterName)
                                                    .font(.caption)
                                                    .foregroundColor(.white)

                                                // セリフ
                                                Text(dialogue.dialogueText)
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
                                                // 右側キャラのアイコン（セシル）
                                                Image("cecil_icon")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(Circle())
                                            }

                                            if !isRight {
                                                Spacer()
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 4)
                                        .id(index)
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
                                ForEach(42...currentIndex, id: \.self) { index in
                                    let dialogue = groupchatDialogues[index]
                                    let isRight = dialogue.characterName == "セシル"

                                    HStack(alignment: .bottom, spacing: 8) {
                                        if isRight {
                                            Spacer()
                                        }

                                        if !isRight {
                                            // 左側キャラのアイコン（アレックとコニー）
                                            Image(getCharacterIcon(for: dialogue.characterName))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }

                                        VStack(alignment: isRight ? .trailing : .leading, spacing: 4) {
                                            // キャラクター名
                                            Text(dialogue.characterName)
                                                .font(.caption)
                                                .foregroundColor(.secondary)

                                            // セリフ
                                            Text(dialogue.dialogueText)
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
                                            // 右側キャラのアイコン（セシル）
                                            Image("cecil_icon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }

                                        if !isRight {
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
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

                //戻るボタン
                HStack{
                    Spacer()
                    VStack{
                        Button(action: {
                            path.removeLast()
                        }) {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(.top, 30)
                        }
                        Spacer()
                    }
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
                    Image("Alec")
                        .resizable()
                        .frame(width: 300, height: 700)
                        .offset(x:-300)
                    Image("Cecil")
                        .resizable()
                        .frame(width: 250, height: 450)
                        .offset(x:0)
                    Image("Cony")
                        .resizable()
                        .frame(width: 250, height: 450)
                        .offset(x:300)

                } else if current.characterName == "セシル" {
                    Image("Alec")
                        .resizable()
                        .frame(width: 250, height: 650)
                        .offset(x:-300)
                    Image("Cecil")
                        .resizable()
                        .frame(width: 300, height: 500)
                        .offset(x:0)
                    Image("Cony")
                        .resizable()
                        .frame(width: 250, height: 450)
                        .offset(x:300)

                } else if current.characterName == "コニー"{
                    Image("Alec")
                        .resizable()
                        .frame(width: 250, height: 650)
                        .offset(x:-300)
                    Image("Cecil")
                        .resizable()
                        .frame(width: 250, height: 450)
                        .offset(x:0)
                    Image("Cony")
                        .resizable()
                        .frame(width: 300, height: 500)
                        .offset(x:300)

                }else if current.characterName == "ブライアン" {
                    HStack{
                        Image("Brian")
                            .resizable()
                            .frame(width: 350, height: 500)
                            .offset(x:400)
                        Image("Curl")
                            .resizable()
                            .frame(width: 250, height: 550)
                            .offset(x:-400)
                    }
                }
                else if current.characterName == "カール" {
                    HStack{
                        Image("Brian")
                            .resizable()
                            .frame(width: 300, height: 450)
                            .offset(x:400)
                        Image("Curl")
                            .resizable()
                            .frame(width: 300, height: 600)
                            .offset(x:-400)
                    }
                }
                else {
                    HStack{
                        Image("Teacher")
                            .resizable()
                            .frame(width: 350, height: 500)
                    }
                }

                //吹き出し
                Image("speech_bubble_beige")
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
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                .offset(x:400,y:300)

                //戻るボタン
                HStack{
                    Spacer()
                    VStack{
                        Button(action: {
                            path.removeLast()
                        }) {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(.top, 30)
                        }
                        Spacer()
                    }
                }

                //セリフボタン
                HStack {
                    VStack {
                        Button(action: {
                            isShowingLog.toggle()
                        }) {
                            Image("chat")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                        }
//                            .frame(width: 50, height: 50) // タッチエリアを制限

                        Spacer()
                    }
                    Spacer()
                }
                .padding(50)
                .zIndex(2)

                if isShowingLog {
                    GeometryReader { geometry in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(1...currentIndex, id: \.self) { index in
                                    let dialogue = groupchatDialogues[index]
                                    let isRight = dialogue.characterName == "セシル"

                                    HStack(alignment: .bottom, spacing: 8) {
                                        if isRight {
                                            Spacer()
                                        }

                                        if !isRight {
                                            // 左側キャラのアイコン（アレックとコニー）
                                            Image(getCharacterIcon(for: dialogue.characterName))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }

                                        VStack(alignment: isRight ? .trailing : .leading, spacing: 4) {
                                            // キャラクター名
                                            Text(dialogue.characterName)
                                                .font(.caption)
                                                .foregroundColor(.white)

                                            // セリフ
                                            Text(dialogue.dialogueText)
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
                                            // 右側キャラのアイコン（セシル）
                                            Image("cecil_icon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }

                                        if !isRight {
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .id(index)
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
                                ForEach(93...currentIndex, id: \.self) { index in
                                    let dialogue = groupchatDialogues[index]

                                    HStack(alignment: .bottom, spacing: 8) {
                                        // 全員のアイコンを左側に表示
                                        Image(getCharacterIcon(for: dialogue.characterName))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())

                                        VStack(alignment: .leading, spacing: 4) {
                                            // キャラクター名
                                            Text(dialogue.characterName)
                                                .font(.caption)
                                                .foregroundColor(.secondary)

                                            // セリフ
                                            Text(dialogue.dialogueText)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .font(.body)
                                                .foregroundColor(.black)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(Color.white)
                                                )
                                        }
                                        .frame(maxWidth: 250, alignment: .leading)

                                        Spacer() // 右側に余白を作る
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
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

                //戻るボタン
                HStack{
                    Spacer()
                    VStack{
                        Button(action: {
                            path.removeLast()
                        }) {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(.top, 30)
                        }
                        Spacer()
                    }
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

                //戻るボタン
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
            .onTapGesture {
                if currentIndex < groupchatDialogues.count - 1 {
                    currentIndex += 1
                }
            }
        }
    }

    private func getCharacterIcon(for characterName: String) -> String {
        switch characterName {
        case "アレック":
            return "alec_icon"
        case "コニー":
            return "cony_icon"
        case "ブライアン":
            return "brian_icon"
        case "カール":
            return "curl_icon"
        case "ケビン":
            return "kevin_icon"
        case "ロビー":
            return "robby_icon"
        case "サンドラ":
            return "sandra_icon"
        default:
            return "default_icon" // デフォルトアイコン
        }
    }
}
