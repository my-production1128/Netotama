//
//  DezitamaApp.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//

import SwiftUI

@main
struct DezitamaApp: App {
    @StateObject private var gameManager = GameManager.shared
    @StateObject private var musicplayer = SoundPlayer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .environmentObject(musicplayer)
        }
    }
}
