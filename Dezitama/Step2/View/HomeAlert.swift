//
//  HomeAlert.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/05.
//
import SwiftUI

struct HomeAlert: View {
    @EnvironmentObject var musicplayer: SoundPlayer
    @Binding var path: NavigationPath
    @Binding var isBackMap: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.001)
                .edgesIgnoringSafeArea(.all)
            
            Image("arart")
                .resizable()
                .scaledToFit()
                .frame(width: 600)
            Group{
                HStack {
                    Button {
                        musicplayer.playSE(fileName: "button_SE")
                        path.removeLast()
                    }label: {
                        Image("arart_yes")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                    }
                    Button {
                        musicplayer.playSE(fileName: "button_SE")
                        isBackMap = false
                    }label: {
                        Image("arart_no")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                    }
                }
            }.offset(x: 0, y: 150)
        }
    }
}
