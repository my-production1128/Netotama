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

//step1の分岐なしのストーリー用
struct Dialogue: Identifiable {
    let id = UUID()
    let storyId: String
    let sceneId: String
    let characterName: String
    let dialogueText: String
    let background: String
    let talkingPeople: String?           // TalkingPeople
    let leftCharacter: String?           // LeftCharacter
    let centerCharacter: String?         // CenterCharacter
    let rightCharacter: String?          // RightCharacter
    let oneCharacter: String?            // OneCharacter
    let twoCharacter: String?            // TwoCharacter
    let onePerson: String?               // OnePerson
    let leftChat: String?                // LeftChat
    let rightChat: String?               // RightChat
}

struct Dialogue2: Identifiable {
    let id = UUID()
    let storyId: String
    let sceneId: String
    let viewType: ViewType
    let characterName: String?
    let dialogueText: String?
    let nextSceneId: String?
    let isChoice: Bool
    let choice1Text: String?
    let choice1Percentage: String?
    let choice1NextSceneId: String?
    let choice2Text: String?
    let choice2Percentage: String?
    let choice2NextSceneId: String?
    let background: String?
    let talkingPeople: String?           // TalkingPeople
    let leftCharacter: String?           // LeftCharacter
    let centerCharacter: String?         // CenterCharacter
    let rightCharacter: String?          // RightCharacter
    let oneCharacter: String?            // OneCharacter
    let twoCharacter: String?            // TwoCharacter
    let onePerson: String?               // OnePerson
    let bgm: String?
}

enum ViewType: String {
    case dialogue
//    case choice
    case chat
    case start
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


