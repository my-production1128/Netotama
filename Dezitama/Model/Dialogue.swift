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

struct NetomoBranching: Identifiable {
    let id = UUID()
    let storyId: String
    let sceneId: String
    let sceneType: String
    let icon: String
    let characterName: String
    let leftCharacter: String
    let rightCharacter: String
    let text: String
    let background: String
    let speechBubble: String
    let nextSceneId: String
    let isChoice: Bool?
    let choiceText1: String
    let choiceText2: String
}
