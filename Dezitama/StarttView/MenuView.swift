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
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(isOpen ? 0.7 : 0)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isOpen = false
                    }
                }

            HStack {
                Spacer()

                ZStack {
                    HStack {
                        Spacer()

                        ZStack {
                            Image("AboutApp")
                                .resizable()
                                .scaledToFill()
                                .frame(width: maxWidth * 0.25)
                                .clipped()

                            VStack(spacing: 20) {
                                Text("アプリについて")
                                    .foregroundColor(.black)
                                    .font(.largeTitle)
                                    .padding()

                                Button {
                                    path.append(ViewBuilderPath.Credit)
                                    isOpen = false
                                } label: {
                                    Text("・クレジット")
                                        .foregroundColor(.black)
                                        .font(.title3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }

                                Button {
                                    path.append(ViewBuilderPath.HowToUse)
                                    isOpen = false
                                } label: {
                                    Text("・アプリの使い方")
                                        .foregroundColor(.black)
                                        .font(.title3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }

                                Spacer()
                            }
                            .padding(.top, 100)
                        }
                        .frame(width: maxWidth * 0.25)
                        .offset(x: isOpen ? 0 : maxWidth)
                        .animation(.easeInOut(duration: 0.3), value: isOpen)

                    }
                }
            }
        }
    }
}

struct Credit : View {
    var body: some View {
        ZStack{
        Image("credit")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
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

            let imageNames = ["tutrial_01", "tutrial_02", "tutrial_03", "tutrial_04"]

            ScrollView(.vertical) {
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
