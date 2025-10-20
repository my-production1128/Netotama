//
//  Untitled.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/05.
//
import SwiftUI

struct ChatLogView: View {
    @EnvironmentObject var musicplayer: SoundPlayer
    @Binding var isChatLogVisible: Bool
    let conversationHistory: [Branching]
    

    var body: some View {
        GeometryReader { innerGeometry in
            ZStack(alignment: .leading) {
                Color.black.opacity(0.001)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        musicplayer.playSE(fileName: "button_SE")
                        withAnimation(.easeOut(duration: 0.3)) {
                            isChatLogVisible = false
                        }
                    }
                    .zIndex(0)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            if conversationHistory.isEmpty {
                                // 💬 セリフがまだないとき
                                VStack(spacing: 16) {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("まだセリフがないから、ストーリーを進めてね！")
                                        .font(.custom("MPLUS1-Regular", size: 22))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.4))
                                        .cornerRadius(16)
                                }
                                .frame(maxWidth: .infinity, minHeight: innerGeometry.size.height)
                            } else {
                                ForEach(conversationHistory, id: \.id) { scene in
                                    let isRight = scene.characterName == scene.rightCharacter
                                    let characterName = CharacterName(rawValue: scene.characterName)?.displayName ?? "不明"
                                    
                                    HStack(alignment: .bottom, spacing: 8) {
                                        if !isRight {
                                            Image(scene.icon)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        }
                                        
                                        VStack(alignment: isRight ? .trailing : .leading, spacing: 4) {
                                            Text(characterName)
                                                .font(.custom("MPLUS1-Regular", size: 16))
                                                .foregroundColor(.white)
                                            
                                            RubyLabelRepresentable(
                                                attributedText: scene.text
                                                    .replacingOccurrences(of: "<br>", with: "\n")
                                                    .createRuby(font: .customFont(ofSize: 22),
                                                                color: .black),
                                                font: .systemFont(ofSize: 20),
                                                textColor: .black,
                                                textAlignment: .left,
                                                targetWidth: 270
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
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: isRight ? .trailing : .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .id(scene.id)
                                }
                            }



                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.7))
                    .frame(width: innerGeometry.size.width / 2)
                    .onAppear {
                        if let last = conversationHistory.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .zIndex(1)
                .transition(.move(edge: .leading))
            }
        }
        .zIndex(1)
    }
}
