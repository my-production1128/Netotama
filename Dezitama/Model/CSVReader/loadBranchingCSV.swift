//
//  Untitled.swift
//  Dezitama
//
//  Created by 濱松未波 on 2025/09/26.
//
import Foundation


func loadBranchingCSV(fileName: String) -> [Branching] {
    var result: [Branching] = []

    guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("❌ ファイルが見つかりません: \(fileName).csv")
        return []
    }

    do {
        let csv = try String(contentsOfFile: path, encoding: .utf8)
        let rows = csv.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        for (i, row) in rows.enumerated() {
            if i == 0 { continue }
            let cols = row.components(separatedBy: ",")

            // CSVのヘッダーを基に正しい列数を取得
            let requiredColumnCount = 23
                    guard cols.count >= requiredColumnCount else {
                        print("❌ 列が不足しています (必要: \(requiredColumnCount), 実際: \(cols.count)) line \(i): \(row)")
                        continue
                    }

            // isChoiceの読み込み（インデックス11）
            let isChoice: Bool? = {
                let raw = cols[11].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if raw == "true" || raw == "1" {
                    return true
                } else if raw == "false" || raw == "0" {
                    return false
                } else {
                    return nil
                }
            }()

            // Percentageの読み込みとDouble型への変換
            let choice1Percentage = Double(cols[13])
            let choice2Percentage = Double(cols[16])
            let choice3Percentage = Double(cols[19])

            let b = Branching(
                storyId: cols[0],
                sceneId: cols[1],
                sceneType: cols[2],
                groupName: cols[3],
                icon: cols[4],
                characterName: cols[5],
                leftCharacter: cols[6],
                centerCharacter: cols[7],
                rightCharacter: cols[8],
                text: cols[9],
                nextSceneId: cols[10],
                isChoice: isChoice,
                choice1Text: cols[12],
                choice1Percentage: choice1Percentage,
                choice1NextSceneId: cols[14],
                choice2Text: cols[15],
                choice2Percentage: choice2Percentage,
                choice2NextSceneId: cols[17],
                choice3Text: cols[18],
                choice3Percentage: choice3Percentage,
                choice3NextSceneId: cols[20],
                bgm: cols[21],
                background: cols[22]
            )

            result.append(b)
        }
    } catch {
        print("CSV読み込みエラー：\(error)")
    }
    return result
}

