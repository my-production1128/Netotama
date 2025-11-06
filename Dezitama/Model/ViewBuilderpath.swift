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
    case MapViewBad
    case MapViewHappy
    
//    分岐ありのストーリー
    case GoodStoryBranchView(String, Int, GameMode)

    case Credit
//    チュートリアル画面
    case HowToUse
    
    case ChoiceView
    case ButtonExample
    case TermsOfServiceView

    case StoryProgressView(stageIndex: Int, stageId: Int)
    case ChatMessageView(stageIndex: Int, initialSceneId: String)
}
