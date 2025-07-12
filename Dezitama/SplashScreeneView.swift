//
//  SplashScreeneView.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/07/12.
//
import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opsity = 0.5
    // LottieViewの表示管理
    @State var isLottieViewVisible: Bool = true

    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                if isLottieViewVisible{
                    LottieView(filename: "egg_start_ver2")
                        .ignoresSafeArea()
                        .background(Color.clear)
                }
            }
            .background {
                Color(red: 0.68, green: 0.93, blue: 0.93)
                    .ignoresSafeArea()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
