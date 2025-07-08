//
//  Dialogue.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//


import Foundation

struct Dialogue: Identifiable {
    let id = UUID()
    let storyId: String
    let sceneId: String
    let characterName: String
    let dialogueText: String
    let background: String
}
