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
