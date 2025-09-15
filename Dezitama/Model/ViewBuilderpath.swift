//
//  ViewBuilderPath.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/07/09.
//

enum ViewBuilderPath: Hashable {
//    最初の画面
    case ContentView
//    ストーリー選択画面
    case NoteView
//    分岐ありのストーリー
    case GoodStoryBranchView(String)

    case GroupchatView
    case kakusanView
    case NetomoView
    case Credit
//    チュートリアル画面
    case HowToUse
}
