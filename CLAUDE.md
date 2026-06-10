# mac-notice

Macのカスタム通知CLIツール。画像・音・テキストを自由に設定できる。

## ビルドと実行

```bash
make build      # ビルドのみ
make app        # .appバンドル付きビルド
make install    # /usr/local/bin にインストール
make uninstall  # アンインストール
```

## 使い方

```bash
mac-notice --title "タイトル" [オプション]
mac-notice --help  # ヘルプ表示
```

## 開発

- Swift 6.0+ / macOS 12+
- `NSUserNotification` API（権限不要、CLI から直接動作）
- `contentImage` で通知に画像添付可能

## コーディング規約

- `any` は使用しない
- deprecated API には警告を抑制しない（代替が機能しない限り）
