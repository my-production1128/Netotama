//
//  Dialogue.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//
import Foundation


//step1の分岐なしのストーリー用
struct Dialogue: Identifiable {
    let id = UUID()
    let storyId: String
    let sceneId: String
    let characterName: String
    let dialogueText: String
    let background: String
}


//step2の分岐ありのストーリー
struct Branching: Identifiable {
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


//scvのキャラクター名を日本語に変換
enum CharacterName: String {
//    ニック
    case Nick
    case Nick_angry
    case Nick_normal

//    カール
    case Curl
    case Curl_normal
    case Curl_anixiety
    case Curl_happy
    case Curl_sorry
    case Curl_tear

//    お母さん
    case Mother
    case Mother_normal

//    アレック
//    コニー
//    セシル


    var displayName: String {
        switch self {
        case .Nick: return "ニック"
        case .Nick_angry: return "ニック"
        case .Nick_normal: return "ニック"

        case .Curl: return "カール"
        case .Curl_normal: return "カール"
        case .Curl_anixiety: return "カール"
        case .Curl_happy: return "カール"
        case .Curl_sorry: return "カール"
        case .Curl_tear: return "カール"

        case .Mother: return "カールのお母さん"
        case .Mother_normal: return "カールのお母さん"
        }
    }
}
