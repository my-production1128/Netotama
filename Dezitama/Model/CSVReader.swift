//
//  CSVReader.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//
import Foundation

enum CSVError: Error {
    case fileNotFound
    case invalidFormat
    case readError(Error)
}

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


func loadNetomoBranchingCSV(fileName: String) -> [NetomoBranching] {
    var result: [NetomoBranching] = []

    guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("❌ ファイルが見つかりません: \(fileName).csv")
        return []
    }

    do {
        let csv = try String(contentsOfFile: path, encoding: .utf8)
        let rows = csv.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        for (i, row) in rows.enumerated() {
            if i == 0 { continue } // ヘッダ行スキップ
            let cols = row.components(separatedBy: ",")

            guard cols.count >= 14 else {
                print("❌ 列が足りない line \(i): \(cols)")
                continue
            }

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

            let b = NetomoBranching(
                storyId: cols[0],
                sceneId: cols[1],
                sceneType: cols[2],
                icon: cols[3],
                characterName: cols[4],
                leftCharacter: cols[5],
                rightCharacter: cols[6],
                text: cols[7],
                background: cols[8],
                speechBubble: cols[9],
                nextSceneId: cols[10],
                isChoice: isChoice,
                choiceText1: cols[12],
                choiceText2: cols[13]
            )

            result.append(b)
        }
    } catch {
        print("CSV読み込みエラー：\(error)")
    }

    return result
}
