//
//  final.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/20.
//
import SwiftUI

struct finalStarsView: View {
    let finalStars: Int
    @Binding var path: NavigationPath
    @EnvironmentObject var musicplayer: SoundPlayer

    var body: some View {
        ZStack {
            Image("final_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            Image("final_score")
                .resizable()
                .scaledToFit()
                .frame(width: 500)

                switch finalStars {
                case 1:
                    Image("final_1star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                case 2:
                    Image("final_2star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                case 3:
                    Image("final_3star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                default:
                    Image("final_0star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                }

            Button {
                musicplayer.playSE(fileName: "button_SE")
                path.removeLast()
            } label: {
                Image("homebutton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
            }
            .offset(x: 220, y: 250)
        }
    }
}
