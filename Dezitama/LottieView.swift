//
//  q.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/07/10.
//
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var contentView = SplashScreenView()
    var animationView = LottieAnimationView()

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(filename)
        animationView.contentMode = .scaleAspectFill
        animationView.play()
//        animationView.loopMode = .loop

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        if contentView.isLottieViewVisible {
            animationView.play{ finished in
                contentView.isLottieViewVisible = false
            }
        }
    }
}
