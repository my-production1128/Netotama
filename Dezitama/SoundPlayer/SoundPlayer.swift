//
//  Soundplater.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/10/01.
//
import UIKit
import AVFoundation
import Combine

class SoundPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {

    // 💡 BGMの状態をViewから監視できるように @Published を付けて追加
    @Published var currentBGMFileName: String?

    // 💡 修正点1: BGM専用のプレイヤー
    var bgm_player: AVAudioPlayer?

    // 💡 修正点2: SE専用のプレイヤー（画面遷移待ち用）
    var se_player: AVAudioPlayer?

    var completionHandler: (() -> Void)? // SE再生完了用

    // 汎用的なオーディオプレイヤー初期化ヘルパー (変更なし)
    private func setupPlayer(fileName: String) throws -> AVAudioPlayer {
        guard let musicData = NSDataAsset(name: fileName)?.data else {
            throw NSError(domain: "SoundPlayerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "音源 '\(fileName)'が見つかりません。"])
        }
        return try AVAudioPlayer(data: musicData)
    }

    // MARK: - BGM再生メソッド
    func playBGM(fileName: String) {

        // 同じBGMが再生中なら、二重に再生処理を実行せず、即座に終了する
        if currentBGMFileName == fileName && bgm_player?.isPlaying == true {
            return
        }
        
        // BGMごとの音量設定
        let bgmVolumes: [String: Float] = [
            "arasuzi_bgm": 0.2,
            "chat_bgm": 0.3,
            "classroom_bgm": 0.5,
            "matome_bgm": 0.5,
            "news_bgm": 0.5,
            "park_bgm": 0.5,
            "room_bgm": 0.5,
            "start_bgm": 0.4,
            "island_bgm": 0.5
        ]

        do {
            // 古いBGMがあれば停止
            bgm_player?.stop()

            bgm_player = try setupPlayer(fileName: fileName)
            bgm_player?.numberOfLoops = -1 // 無限ループ
            bgm_player?.delegate = nil
            
            // 音量を設定（デフォルトは0.5）
            bgm_player?.volume = bgmVolumes[fileName] ?? 0.5

            bgm_player?.play()

            // 実行されたらファイル名を更新
            currentBGMFileName = fileName

        } catch {
            print("BGM再生エラー: \(error.localizedDescription)")
            currentBGMFileName = nil // エラー時はクリア
        }
    }

    // MARK: - 効果音再生メソッド (BGMを停止させない)
    func playSE(fileName: String, completion: (() -> Void)? = nil) {
        // 💡 修正点4: se_playerを使用し、BGMプレイヤーには触らない
        se_player?.stop() // 古いSEがあれば停止

        do {
            se_player = try setupPlayer(fileName: fileName)
            se_player?.numberOfLoops = 0 // ループさせない

            se_player?.delegate = self // 完了通知を受け取るためデリゲートを設定
            self.completionHandler = completion

            se_player?.play()
        } catch {
            print("SE再生エラー: \(error.localizedDescription)")
            completion?()
        }
    }

    /// 全ての音楽を停止
    func stopAllMusic() {
        bgm_player?.stop()
        se_player?.stop()
        // 💡 停止時はBGMファイル名をクリア
        currentBGMFileName = nil
    }

    // MARK: - AVAudioPlayerDelegate (SEプレイヤーのデリゲート)
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 💡 修正点5: 再生完了したのがse_playerであることを確認
        if player == se_player && flag {
            self.completionHandler?()
            self.completionHandler = nil
        }
    }
}
