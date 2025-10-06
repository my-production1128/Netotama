//
//  q.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/07/10.
//
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    // ✅ 修正点1: 引数名をfilenameからnameに変更
    var name: String
    // ✅ 修正点2: ループ方法を指定するプロパティを追加
    var loopMode: LottieLoopMode = .playOnce

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()

        // ファイル名（name）でアニメーションを読み込み
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFill

        // ✅ 修正点3: 指定されたloopModeを設定
        animationView.loopMode = loopMode

        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>){}
}
