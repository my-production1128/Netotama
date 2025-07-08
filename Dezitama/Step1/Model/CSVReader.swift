//
//  CSVReader.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//
import Foundation

func loadCSV(fileName: String) -> [Dialogue] {
    var result: [Dialogue] = []

    guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
//        print("ファイルが見つかりません")
        return []
    }

    do {
        let csvData = try String(contentsOfFile: path, encoding: .utf8)
        let rows = csvData.components(separatedBy: .newlines)
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 5 {
                let dialogue = Dialogue(
                    storyId: columns[0],
                    sceneId: columns[1],
                    characterName: columns[2],
                    dialogueText: columns[3],
                    background: columns[4]
                )
                result.append(dialogue)
            }
        }
    } catch {
        print("読み込みエラー: \(error)")
    }

    return result
}
