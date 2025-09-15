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
        print("ファイルが見つかりません")
        return []
    }

    do {
        let csvData = try String(contentsOfFile: path, encoding: .utf8)
        let rows = csvData.components(separatedBy: .newlines)
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 14 {
                let dialogue = Dialogue(
                    storyId: columns[0],
                    sceneId: columns[1],
                    characterName: columns[2],
                    dialogueText: columns[3],
                    background: columns[4],
                    talkingPeople: columns.count > 5 ? (columns[5].isEmpty ? nil : columns[5]) : nil,
                    leftCharacter: columns.count > 6 ? (columns[6].isEmpty ? nil : columns[6]) : nil,
                    centerCharacter: columns.count > 7 ? (columns[7].isEmpty ? nil : columns[7]) : nil,
                    rightCharacter: columns.count > 8 ? (columns[8].isEmpty ? nil : columns[8]) : nil,
                    oneCharacter: columns.count > 9 ? (columns[9].isEmpty ? nil : columns[9]) : nil,
                    twoCharacter: columns.count > 10 ? (columns[10].isEmpty ? nil : columns[10]) : nil,
                    onePerson: columns.count > 11 ? (columns[11].isEmpty ? nil : columns[11]) : nil,
                    leftChat: columns.count > 12 ? (columns[12].isEmpty ? nil : columns[12]) : nil,
                    rightChat: columns.count > 13 ? (columns[13].isEmpty ? nil : columns[13]) : nil
                )
                result.append(dialogue)
            }
        }
    } catch {
        print("読み込みエラー: \(error)")
    }
    return result
}



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
            let headers = rows[0].components(separatedBy: ",")
            let columnCount = headers.count

            guard cols.count >= columnCount else {
                print("❌ 列が足りません line \(i): \(cols)")
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
            let choice1Percentage = Double(cols[14])
            let choice2Percentage = Double(cols[18])
            let choice3Percentage = Double(cols[22])

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
                choice1Type: cols[13],
                choice1Percentage: choice1Percentage,
                choice1NextSceneId: cols[15],
                choice2Text: cols[16],
                choice2Type: cols[17],
                choice2Percentage: choice2Percentage,
                choice2NextSceneId: cols[19],
                choice3Text: cols[20],
                choice3Type: cols[21],
                choice3Percentage: choice3Percentage,
                choice3NextSceneId: cols[23],
                bgm: cols[24],
                background: cols[25]
            )

            result.append(b)
        }
    } catch {
        print("CSV読み込みエラー：\(error)")
    }
    return result
}
