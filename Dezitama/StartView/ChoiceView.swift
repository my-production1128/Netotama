//
//  ChoiceView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/06/27.
//

import SwiftUI

struct ChoiceView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("choice_background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    Button {
                        path.append(ViewBuilderPath.MapViewBad)
                    } label: {
                        Image("Bad_Button")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.35)
                            .position(
                                x: geometry.size.width * 0.5,
                                y: geometry.size.height * 0.35
                            )
                    }
                    
                    Button {
                            path.append(ViewBuilderPath.MapViewHappy)
                    } label: {
                        Image("Good_Button")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.4)
                            .position(
                                x: geometry.size.width * 0.5,
                                y: geometry.size.height * 0.25
                            )
                    }
//                    .disabled(!gameManager.isHappyUnlocked)
                }
            }
        }
    }
}

