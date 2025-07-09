---
name: issue template
about: バグや機能追加の際に使用します。再現手順や期待される動作を書いてください
title: ''
labels: ''
assignees: ''

---

name: バグ報告
description: 不具合や想定外の動作について報告します
title: "[バグ]: "
labels: ["bug", "triage"]
assignees:
  - your-username-here
body:
  - type: markdown
    attributes:
      value: |
        🐞 バグのご報告ありがとうございます！以下の項目をご記入ください。

  - type: textarea
    id: summary
    attributes:
      label: 概要
      description: どんな問題が発生したのか、簡潔に説明してください。
      placeholder: 例）アプリ起動時にクラッシュが発生します。
    validations:
      required: true

  - type: textarea
    id: steps
    attributes:
      label: 再現手順
      description: 問題を再現できる手順を、番号付きで記述してください。
      placeholder: |
        1. アプリを起動する
        2. ホーム画面で「設定」をタップする
        3. クラッシュが発生する
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: 期待される動作
      description: 本来どのように動作することを期待していたかを記載してください。
      placeholder: 設定画面が正常に表示されることを期待していました。
    validations:
      required: true

  - type: textarea
    id: evidence
    attributes:
      label: 補助資料・ログ・スクリーンショット
      description: エラーログ、スクリーンショット、関連コードなどがあれば貼り付けてください。
      placeholder: ログや画像をここに貼り付けてください。
      render: shell
    validations:
      required: false

  - type: checkboxes
    id: terms
    attributes:
      label: 行動規範への同意
      description: Issueを送信することで、[行動規範](https://example.com)に同意したことになります。
      options:
        - label: このプロジェクトの行動規範に同意します
          required: true
