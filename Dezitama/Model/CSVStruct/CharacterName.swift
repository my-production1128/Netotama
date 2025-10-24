//
//  Untitled.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/09/26.
//

import Foundation
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
    case Alec
    case Alec_normal
    case Alec_anxiety
    case Alec_disgusting
    case Alec_smile
    case Alec_surprised
    case Alec_sorry

//    コニー
    case Cony
    case Cony_normal
    case Cony_anixiety
    case Cony_irritation
    case Cony_panic
    case Cony_smile
    case Cony_sorry
    case Cony_surprised
    case Cony_trouble

//    セシル
    case Cecil
    case Cecil_normal
    case Cecil_anixiety
    case Cecil_irritation
    case Cecil_panic
    case Cecil_smile
    case Cecil_sorry
    case Cecil_surprised
    case Cecil_trouble
    case Cecil_fun

//    先生
    case Teacher
    case Teacher_normal
    case Teacher_irritation

//    ブライアン
    case Brian
    case Brian_normal
    case Brian_trouble

//    サンドラ
    case Sandra
    case Sandra_sorry

//    ロビー
    case Robbie
    case Robbie_irritaion

    case Kevin
    case Kevin_sorry
    case Kevin_normal



    var displayName: String {
        switch self {
//            ニック
        case .Nick: return "ニック"
        case .Nick_angry: return "ニック"
        case .Nick_normal: return "ニック"

//            カール
        case .Curl: return "カール"
        case .Curl_normal: return "カール"
        case .Curl_anixiety: return "カール"
        case .Curl_happy: return "カール"
        case .Curl_sorry: return "カール"
        case .Curl_tear: return "カール"

//            カールのお母さん
        case .Mother: return "カールのお母さん"
        case .Mother_normal: return "カールのお母さん"

//            アレック
        case .Alec: return "アレック"
        case .Alec_normal: return "アレック"
        case .Alec_anxiety: return "アレック"
        case .Alec_disgusting: return "アレック"
        case .Alec_smile: return "アレック"
        case .Alec_surprised: return "アレック"
        case .Alec_sorry: return "アレック"

//            コニー
        case .Cony: return "コニー"
        case .Cony_normal: return "コニー"
        case .Cony_anixiety: return "コニー"
        case .Cony_irritation: return "コニー"
        case .Cony_panic: return "コニー"
        case .Cony_smile: return "コニー"
        case .Cony_sorry: return "コニー"
        case .Cony_surprised: return "コニー"
        case .Cony_trouble: return "コニー"

//            セシル
        case .Cecil: return "セシル"
        case .Cecil_normal: return "セシル"
        case .Cecil_anixiety: return "セシル"
        case .Cecil_irritation: return "セシル"
        case .Cecil_panic: return "セシル"
        case .Cecil_smile: return "セシル"
        case .Cecil_sorry: return "セシル"
        case .Cecil_surprised: return "セシル"
        case .Cecil_trouble: return "セシル"
        case .Cecil_fun: return "セシル"

//            先生
        case .Teacher: return "先生"
        case .Teacher_normal: return "先生"
        case .Teacher_irritation: return "先生"

//            ブライアン
        case .Brian: return "ブライアン"
        case .Brian_normal: return "ブライアン"
        case .Brian_trouble: return "ブライアン"

//            サンドラ
        case .Sandra: return "サンドラ"
        case .Sandra_sorry: return "サンドラ"
//            ロビー
        case .Robbie: return "ロビー"
        case .Robbie_irritaion: return "ロビー"

        case .Kevin: return "ケビン"
        case .Kevin_sorry: return "ケビン"
        case .Kevin_normal: return "ケビン"
        }
    }
}
