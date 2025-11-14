//
//  Dialogue.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//
import Foundation

struct StageData: Identifiable {
    let id: Int
    let csvFileName: String
    var dialogues: [Dialogue2] = []
    
    mutating func loadDialogues() {
        self.dialogues = loadCSV2(fileName: csvFileName)
    }
}

struct Dialogue2: Identifiable {
    let id = UUID()
    var storyId: String = ""
    var sceneId: String = ""
    var viewType: ViewType = .chat
    var characterName: String? = nil
    var dialogueText: String? = nil
    var nextSceneId: String? = nil
    var isChoice: Bool = false
    var choice1Text: String? = nil
    var choice1Percentage: Double?
    var choice1NextSceneId: String? = nil
    var choice2Text: String? = nil
    var choice2Percentage: Double?
    var choice2NextSceneId: String? = nil
    var background: String? = nil
    var talkingPeople: String? = nil
    var leftCharacter: String? = nil
    var centerCharacter: String? = nil
    var rightCharacter: String? = nil
    var oneCharacter: String? = nil
    var twoCharacter: String? = nil
    var onePerson: String? = nil
    var bgm: String? = nil
    var groupName: String? = nil
}


enum ViewType: String {
    case dialogue
    case dialogue_AE
    case chat
    case start
    case screen
    case chat_picture
}

//step2の分岐ありのストーリー
struct Branching: Identifiable {
    let id = UUID()
    let storyId: String
    let sceneId: String
    let sceneType: String
    let groupName: String
    let icon: String
    let characterName: String
    let leftCharacter: String
    let centerCharacter: String
    let rightCharacter: String
    let text: String
    let nextSceneId: String
    let isChoice: Bool?
    let choice1Text: String
    let choice1Percentage: Double?
    let choice1NextSceneId: String
    let choice2Text: String
    let choice2Percentage: Double?
    let choice2NextSceneId: String
    let choice3Text: String
    let choice3Percentage: Double?
    let choice3NextSceneId: String
    let bgm: String
    let background: String
}


