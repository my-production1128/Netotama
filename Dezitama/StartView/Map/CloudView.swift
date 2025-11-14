//
//  CloudView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/10/22.
//

import SwiftUI
import Combine

final class CloudController: ObservableObject {
    static let shared = CloudController()
    
    @Published private var floatingStates: [String: Bool] = [:]
    private var timers: [String: Timer] = [:]
    
    private init() {}
    
    func isFloatingUp(for key: String) -> Bool {
        floatingStates[key] ?? false
    }
    
    func startFloating(for key: String) {
        // 既存のタイマーを確実に停止してから再起動
        stopFloating(for: key)
        
        floatingStates[key] = Bool.random()
        
        // 一定間隔で上下に切り替える
        let interval = Double.random(in: 3.5...5.5)
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            withAnimation(
                .easeInOut(duration: interval)
            ) {
                self.floatingStates[key]?.toggle()
            }
        }
        
        timers[key] = timer
    }
    
    func stopFloating(for key: String) {  // ★ Int → String
        timers[key]?.invalidate()
        timers[key] = nil
        floatingStates[key] = nil
    }
    
    func stopAll() {
        timers.values.forEach { $0.invalidate() }
        timers.removeAll()
        floatingStates.removeAll()
    }
}

struct CloudView: View {
    let id: Int  // stageId
    let imageName: String
    let position: CGPoint
    let geometry: GeometryProxy
    let mode: GameMode
    
    @ObservedObject private var controller = CloudController.shared
    @EnvironmentObject var gameManager: GameManager
    
    // ★ 一意のキーを生成（モードとステージIDの組み合わせ）
    private var uniqueKey: String {
        "\(mode.rawValue)_\(id)"
    }
    
    
    // 解放アイコンの画像名を決定
    private var kaihougImageName: String {
        mode == .bad ? "bad_kaihou" : "good_kaihou"
    }
    
    // このステージに必要な雷/星の数を取得
    private var requiredCount: Int {
        if mode == .bad {
            if id == 4 {
                return 5  // Bad4: 雷5以上
            } else if id == 7 {
                return 12  // Bad7: 雷12以上
            }
        } else if mode == .happy {
            if id == 1 {
                return 5  // Happy1: 雷5以上
            } else if id == 4 {
                return 5  // Happy4: 星5以上
            } else if id == 7 {
                return 12  // Happy7: 星12以上
            }
        }
        return 0
    }
    
    // 残り必要数を計算
    private var remainingCount: Int {
        // Happy1は特殊（Bad側の雷で判定）
        let current: Int
        if mode == .happy && id == 1 {
            current = gameManager.totalThunders
        } else {
            current = mode == .bad ? gameManager.totalThunders : gameManager.totalStars
        }
        return max(0, requiredCount - current)
    }
    
    private var kaihouTextName: String {
        // Happy1は雷で判定
        let icon = (mode == .happy && id == 1) ? "雷" : (mode == .bad ? "雷" : "星")
        return "解放まであと\(icon)\(remainingCount)個"
    }
    
    var body: some View {
            ZStack {
                // 雲の画像
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.42)
                    .offset(y: controller.isFloatingUp(for: uniqueKey) ? -10 : 10)
                
                ZStack{
                    // 解放アイコン
                    Image(kaihougImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.3)
                        .offset(y: controller.isFloatingUp(for: uniqueKey) ? -10 : 10)
                    
                    Text(kaihouTextName)
                        .font(.custom("MPLUS1-Bold", size: 25))
                        .foregroundColor(.white)
                        .frame(width: geometry.size.width * 0.25)
                        .offset(y: controller.isFloatingUp(for: uniqueKey) ? -10 : 10)
                }
            }
            .position(position)
            .onAppear {
                controller.startFloating(for: uniqueKey)
            }
            .onDisappear {
                controller.stopFloating(for: uniqueKey)
            }
        }
    }
