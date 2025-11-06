//
//  MenuView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/07/19.
//
import SwiftUI

struct MenuView: View {
    @Binding var isOpen: Bool
    @Binding var path: NavigationPath
    private let maxWidth = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            // 背景のタップ領域（白の透過）
            Color.white
                .opacity(isOpen ? 0.7 : 0)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isOpen = false
                    }
                }

            // サイドバー本体
            HStack {
                Spacer()

                ZStack {
                    HStack {
                        Spacer()

                        ZStack {
                            Image("AboutApp")
                                .resizable()
                                .scaledToFit()
                                .frame(width: maxWidth * 0.25)
                                .clipped()

                            VStack(spacing: 20) {
                                Text("アプリについて")
                                    .foregroundColor(.black)
                                    .font(Font(UIFont.customFont(ofSize: 35)))
                                    .padding()

                                Button {
                                    path.append(ViewBuilderPath.Credit)
//                                    isOpen = false
                                } label: {
                                    Text("・クレジット")
                                        .foregroundColor(.black)
                                        .font(Font(UIFont.customFont(ofSize: 25)))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }

                                Button {
                                    path.append(ViewBuilderPath.HowToUse)
//                                    isOpen = false
                                } label: {
                                    Text("・アプリの使い方")
                                        .foregroundColor(.black)
                                        .font(Font(UIFont.customFont(ofSize: 25)))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }
                                
                                Button {
                                    path.append(ViewBuilderPath.ButtonExample)
//                                    isOpen = false
                                } label: {
                                    Text("・ボタンの説明")
                                        .foregroundColor(.black)
                                        .font(Font(UIFont.customFont(ofSize: 25)))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }
                                Button {
                                    path.append(ViewBuilderPath.TermsOfServiceView)
                                } label: {
                                    Text("・利用規約")
                                        .foregroundColor(.black)
                                        .font(Font(UIFont.customFont(ofSize: 25)))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }

                                Spacer()
                                Button {
                                    GameManager.shared.deleteAllData()
                                } label: {
                                    Text("。")
                                        .foregroundColor(.black)
                                        .font(Font(UIFont.customFont(ofSize: 25)))
                                }

                            }
                            .padding(.top, 100)
                        }
                        .offset(x: isOpen ? 15 : maxWidth)
                        .frame(width: maxWidth * 0.25)
                        .animation(.easeInOut(duration: 0.3), value: isOpen)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}


struct Credit : View {
    var body: some View {
            ZStack{
                Image("credit_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
                VStack {
                    Image("credit_text")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                        .padding()
                    Image("credit_develop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 750)
                        .padding()
                    Image("credit_creative")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 750)
                        .padding()
                    Image("credit_super")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 750)
                        .padding()
                    Spacer()
                    Text("© 2025 limura Lab., Pref. Univ. of Kumamoto")
                        .foregroundColor(.black)
                        .font(Font(UIFont.customFont(ofSize: 20)))
                        .padding(.bottom, 30)
                }
            }
    }
}

struct HowToUse : View {
    var body: some View {
        ZStack{
            Image("note_background")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height)
                .ignoresSafeArea()

            let imageNames = ["tutrial_01", "tutrial_02", "tutrial_03"]

            VStack(spacing: 0) {
                Image("howtouse")
                    .resizable()
                    .frame(width: 600, height: 100)
                    .padding(.top, 30)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(imageNames, id: \.self) { name in
                            Image(name)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width,
                                       height: UIScreen.main.bounds.height)
                                .clipped()
                        }
                    }
                }
            }
        }
    }
}


struct ButtonExample : View {
    var body: some View {
        
        ZStack{
            Image("button_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
                VStack(spacing:5){
                    Image("button_title")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 100)
                    
                    Image("button_imark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 700, height: 100)
                    
                    Image("button_iland")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 700, height: 100)
                    
                    Image("button_talk")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 700, height: 100)
                    
                    Image("button_home")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 700, height: 100)
                    
                    Image("button_badend")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 700, height: 100)
                    
                    Image("button_master")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 700, height: 100)
            }
        }
    }
}

