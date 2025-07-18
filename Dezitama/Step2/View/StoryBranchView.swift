////
////  NetomoBranchingView.swift
////  Dezitama
////
////  Created by 濱松未波 on 2025/07/17
////
//
//import SwiftUI
//import UIKit
//
//struct NetomoBranchingView2: View {
//    @State private var currentSceneId: String = ""
//    @State private var historyStack: [String] = []
//    @State private var showSpecialView: Bool = false
//    @State private var offsetY: CGFloat = 0.0
//    @State var isPopupVisible: Bool = false
//    @State var nextChat: Bool = false
//    
//    @State private var displayedText = ""
//    @State private var currentCharIndex = 0
//    @State private var timer: Timer? = nil
//    @State private var isTypingComplete: Bool = false
//    @State private var shouldSkipTyping: Bool = false
//    
//    @Binding var path: NavigationPath
//    @Binding var netomoScene: NetomoBranching
//    @Binding var netomoBranchings: [NetomoBranching]
//    
//    // シーンタイプを定義するEnum
//    enum SceneType: String {
//        case chat = "chat"
//        case talk = "talk"
//        
//        case unknown
//        
//        init(rawValue: String) {
//            switch rawValue {
//            case "chat": self = .chat
//            case "talk": self = .talk
//            default: self = .unknown
//            }
//        }
//    }
//    
//    private var branchingMap: [String: NetomoBranching] {
//        var map: [String: NetomoBranching] = [:]
//        for b in netomoBranchings {
//            if map[b.sceneId] == nil {
//                map[b.sceneId] = b
//            } else {
//                print("⚠️ Duplicate sceneId found: \(b.sceneId)")
//            }
//        }
//        return map
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                if let current = branchingMap[currentSceneId] {
//                    VStack {
//                        Spacer()
//                        // switch文による分岐
//                        switch SceneType(rawValue: current.sceneType) {
//                        case .chat:
//                            ChatSceneView(
//                                branchingMap: branchingMap,
//                                initialSceneId: current.sceneId,
//                                onNextScene: { nextId in
//                                    historyStack.append(currentSceneId)
//                                    currentSceneId = nextId
//                                },
//                                netomoScene: $netomoScene,
//                                netomoBranchings: $netomoBranchings,
//                                isPopupVisible: $isPopupVisible
//                            )
//                            
//                        case .talk:
//                            NetomoBranchingView(path: $path, netomoScene: $netomoScene, netomoBranchings: $netomoBranchings)
//
//                        case .unknown:
//                            // 不明なシーンタイプの場合のフォールバック
//                            Text("未対応のシーンタイプです")
//                        }
//                    }
//                    .background {
////                        背景はこのviewに固定で大丈夫
//                        Image(current.background)
//                            .resizable()
//                            .scaledToFill()
//                            .clipped()
//                    }
//                    .ignoresSafeArea()
//                } else {
//                    Text("ストーリーが読み込めませんでしたnetomoBranchView")
//                }
//                
////                 ホームボタンもここのviewに固定で大丈夫
//                HStack {
//                    Spacer()
//                    VStack {
//                        Button {
//                            path.removeLast()
//                        } label: {
//                            Image("home")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 100, height: 100)
//                                .padding(.top, 30)
//                        }
//                        Spacer()
//                    }
//                }
//            }
//            .onAppear {
//                if let first = netomoBranchings.first {
//                    currentSceneId = first.sceneId
//                }
//            }
//        }
//    }
//}
