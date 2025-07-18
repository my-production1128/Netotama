//
//  MenuView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/07/19.
//
import SwiftUI

struct MenuView: View {
    @Binding var isOpen: Bool
    private let maxWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            // 背景の黒半透明（タップで閉じる）
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(isOpen ? 0.7 : 0)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isOpen.toggle()
                    }
                }
            
            // メニュー本体
            HStack {
                Spacer()

                ZStack {
                    Image("AboutApp")
                        .resizable()
                        .scaledToFill()
                        .frame(width: maxWidth * 0.25)
                        .offset(x: isOpen ? 0 : maxWidth)
                        .animation(.easeInOut(duration: 0.3), value: isOpen)
                    
                    if isOpen {
                        VStack(spacing: 20) {
                            Button {
                                // path.append(selectedPath.NetomoView)
                            } label: {
                                Text("アプリについて")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(8)
                            }
                            
                            Button {
                                // path.append(selectedPath.NetomoBranchingView)
                            } label: {
                                Text("クレジット")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(8)
                            }
                        }
                        .transition(.move(edge: .trailing))
                        .animation(.easeInOut(duration: 0.3), value: isOpen)
                    }
                }
            }
        }
    }
}
