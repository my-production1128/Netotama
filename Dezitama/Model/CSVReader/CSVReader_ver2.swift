//
//  CSVReader_ver2.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/10/01.
//

import Foundation

// CSVErrorは既存のファイルにあるので、ここでは定義しない(削除)

func loadCSV2(fileName: String) -> [Dialogue2] {
    var result: [Dialogue2] = []
    guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("ファイルが見つかりません")
        return []
    }

    do {
        let csvData = try String(contentsOfFile: path, encoding: .utf8)
        let rows = csvData.components(separatedBy: .newlines)
        
        guard rows.count > 1 else {
            print("CSVが空です")
            return []
        }
        
        // 1行目をヘッダーとして取得
        let headers = rows[0].components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // 2行目以降をデータとして処理
        for row in rows.dropFirst() {
            guard !row.isEmpty else { continue }
            
            let columns = row.components(separatedBy: ",")
            
            // ヘッダー名から値を取得する関数
            func getValue(_ key: String) -> String? {
                guard let index = headers.firstIndex(of: key),
                      index < columns.count else { return nil }
                let value = columns[index].trimmingCharacters(in: .whitespaces)
                return value.isEmpty ? nil : value
            }
            
            // viewTypeの取得と変換
            guard let viewTypeString = getValue("viewType"),
                  let viewType = ViewType(rawValue: viewTypeString) else {
                print("無効なviewType: \(row)")
                continue
            }
            
            // isChoiceの取得(TRUE/FALSEを判定)
            let isChoiceString = getValue("isChoice")?.uppercased()
            let isChoice = (isChoiceString == "TRUE")
            
            let dialogue = Dialogue2(
                storyId: getValue("storyId") ?? "",
                sceneId: getValue("sceneId") ?? "",
                viewType: viewType,
                characterName: getValue("characterName"),
                dialogueText: getValue("dialogueText"),
                nextSceneId: getValue("nextSceneId"),
                isChoice: isChoice,
                choice1Text: getValue("choice1Text"),
                choice1Percentage: getValue("choice1Percentage"),
                choice1NextSceneId: getValue("choice1NextSceneId"),
                choice2Text: getValue("choice2Text"),
                choice2Percentage: getValue("choice2Percentage"),
                choice2NextSceneId: getValue("choice2NextSceneId"),
                background: getValue("background"),
                talkingPeople: getValue("TalkingPeople"),
                leftCharacter: getValue("LeftCharacter"),
                centerCharacter: getValue("CenterCharacter"),
                rightCharacter: getValue("RightCharacter"),
                oneCharacter: getValue("OneCharacter"),
                twoCharacter: getValue("TwoCharacter"),
                onePerson: getValue("OnePerson"),
                bgm: getValue("bgm")
            )
            result.append(dialogue)
        }
    } catch {
        print("読み込みエラー: \(error)")
    }
    return result
}
