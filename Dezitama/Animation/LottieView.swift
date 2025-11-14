//
//  q.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/07/10.
//
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .playOnce
    var onCompletion: (() -> Void)? // ◀ 1. 完了ハンドラプロパティを追加

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()

        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode

        // ◀ 2. .play() に完了クロージャを渡す
        animationView.play { (finished) in
            // アニメーションが最後まで再生完了したら
            if finished {
                print("LottieView: Animation finished.")
                // ◀ 3. onCompletion が設定されていれば呼び出す
                onCompletion?()
            }
        }

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
