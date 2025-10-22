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
    
    @Published private var floatingStates: [Int: Bool] = [:]
    private var timers: [Int: Timer] = [:]
    
    private init() {}
    
    func isFloatingUp(for id: Int) -> Bool {
        floatingStates[id] ?? false
    }
    
    func startFloating(for id: Int) {
        guard timers[id] == nil else { return } // すでに動作中ならスキップ
        
        floatingStates[id] = Bool.random()
        
        // 一定間隔で上下に切り替える
        let interval = Double.random(in: 3.5...5.5)
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            withAnimation(
                .easeInOut(duration: interval)
            ) {
                self.floatingStates[id]?.toggle()
            }
        }
        
        timers[id] = timer
    }
    
    func stopFloating(for id: Int) {
        timers[id]?.invalidate()
        timers[id] = nil
        floatingStates[id] = nil
    }
    
    func stopAll() {
        timers.values.forEach { $0.invalidate() }
        timers.removeAll()
        floatingStates.removeAll()
    }
}

struct CloudView: View {
    let id: Int
    let imageName: String
    let position: CGPoint
    let geometry: GeometryProxy
    let mode: GameMode
    
    @ObservedObject private var controller = CloudController.shared
    
    var body: some View {
        ZStack{
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width * 0.4)
                .offset(y: controller.isFloatingUp(for: id) ? -10 : 10)
            
//            Image(mode == .happy ? "good_kaihou" : "bad_kaihou")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width * 0.15)
//                .offset(y: controller.isFloatingUp(for: id) ? -55 : -50) // 雲より上に少し浮かせる
//                .shadow(radius: 3)
        }
        .position(position)
        .onAppear {
            controller.startFloating(for: id)
        }
        .onDisappear {
            controller.stopFloating(for: id)
        }
    }
}
