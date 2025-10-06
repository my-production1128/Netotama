//
//  ChatLog2View.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/10/06.
//

import SwiftUI

struct ChatLog2View: View {
    @EnvironmentObject var musicplayer: SoundPlayer
    @Binding var isChatLogVisible: Bool
    let conversationHistory: [Dialogue2]

    var body: some View {
        GeometryReader { innerGeometry in
            ZStack(alignment: .leading) {
                // 半透明背景（タップで閉じる）
                Color.black.opacity(0.001)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        musicplayer.playSE(fileName: "button_SE")
                            isChatLogVisible = false
                    }
                    .zIndex(0)

                // ====== メインスクロール ======
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
                                // 💬 セリフがあるとき
                                ForEach(conversationHistory, id: \.sceneId) { dialogue in
                                    let characterName = dialogue.characterName ?? "不明"
                                    let isRight = (characterName == "コニー")

                                    HStack(alignment: .bottom, spacing: 8) {
                                        // 左キャラ（相手側）
                                        if !isRight {
                                            Image(getCharacterImageName(for: characterName))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        }

                                        // 吹き出し（セリフ）
                                        VStack(alignment: isRight ? .trailing : .leading, spacing: 4) {
                                            Text(characterName)
                                                .font(.custom("MPLUS1-Regular", size: 16))
                                                .foregroundColor(.white)

                                            if let dialogueText = dialogue.dialogueText {
                                                Text(dialogueText.replacingOccurrences(of: "<br>", with: "\n"))
                                                    .font(.custom("MPLUS1-Regular", size: 16))
                                                    .foregroundColor(.black)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .fill(Color.white)
                                                    )
                                                    .frame(maxWidth: 250, alignment: isRight ? .trailing : .leading)
                                            }
                                        }
                                        .frame(maxWidth: 250, alignment: isRight ? .trailing : .leading)

                                        // 右キャラ（コニー側）
                                        if isRight {
                                            Image(getCharacterImageName(for: characterName))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: isRight ? .trailing : .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .id(dialogue.sceneId)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.7))
                    .frame(width: innerGeometry.size.width / 2)
                    .onAppear {
                        if let last = conversationHistory.last {
                            proxy.scrollTo(last.sceneId, anchor: .bottom)
                        }
                    }
                }
                .zIndex(1)
            }
        }
        .zIndex(1)
    }

    // MARK: - キャラクター画像取得ヘルパー
    private func getCharacterImageName(for name: String) -> String {
        switch name {
        case "アレック": return "alec_icon"
        case "セシル": return "cecil_icon"
        case "コニー": return "cony_icon"
        case "ブライアン": return "brian_icon"
        case "カール": return "curl_icon"
        case "ケビン": return "kevin_icon"
        case "ロビー": return "robby_icon"
        case "サンドラ": return "sandra_icon"
        case "先生": return "teacher_icon"
        case "ニック": return "nick_icon"
        default: return "default_icon"
        }
    }
}

