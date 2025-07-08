//
//  ChoiceView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/27.
//

//.border(Color.black, width: 5)



import SwiftUI

struct ChoiceView: View {
    @State private var netomoArray: [Dialogue] = []
    @State private var groupchatArray: [Dialogue] = []
    @State private var kakusanArray: [Dialogue] = []
    
    @State private var currentImageName: String = "note_gurutama"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景ノート画像
                Image(currentImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 850, height: 750)
                    .offset(x: 20, y: -20)
                
                // 右側の切り替えボタン
                VStack {
                    Spacer().frame(height: 20)
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
                
                // ページごと
                switch currentImageName {
                case "note_gurutama":
                    ZStack {
                        NavigationLink(destination: GroupchatView(dialogues: groupchatArray)) {
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
                        NavigationLink(destination: NetomoView(dialogues: netomoArray)) {
                            Image("step1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 100)
                        }
                        .offset(x: 280, y: -180)
                        
                        
                        Image("step2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 100)
                            .offset(x: 300, y: 150)
                    }
                    
                case "note_potitama":
                    ZStack {
                        NavigationLink(destination: KakusanView(dialogues: kakusanArray)) {
                            Image("step1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 100)
                        }
                        .offset(x: 280, y: -180)
                        
                        Image("step2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 100)
                            .offset(x: 300, y: 150)
                    }
                
                    //図鑑
                default:
                    EmptyView()
                }
            }
            .onAppear {
                netomoArray = loadCSV(fileName: "netomo_var8_0")
                groupchatArray = loadCSV(fileName: "groupchat_var5_0")
                kakusanArray = loadCSV(fileName: "kakusan_var5_0")
            }
        }
    }
}
