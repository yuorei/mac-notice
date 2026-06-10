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
- `UNUserNotificationCenter` API を使用（通知許可が必要。`.app` バンドル + 署名がないと許可が下りない）
- `--image` で通知右側に画像添付可能（`UNNotificationAttachment`）
- `--sender` で別アプリのBundle IDを偽装して左アイコンを変更可能（`BundleHook`）

## アプリアイコン（通知左側）

- `Resources/icon.png` が元画像。`make app` 時に `sips` + `iconutil` で `AppIcon.icns` を生成しバンドルに同梱、ad-hoc 署名する
- `Info.plist` の `CFBundleExecutable` / `CFBundlePackageType` / `CFBundleIconFile` は削除しないこと（欠けると `open` で起動できず、通知アイコンも解決されない）
- **重要**: macOSは通知許可取得時点のアイコンをBundle IDごとに永久キャッシュする（usernoted のDB、フルディスクアクセスなしでは消せない）。アイコンを差し替えたら `CFBundleIdentifier` の変更が必要。詳細は README の「アプリアイコン」参照

## コーディング規約

- `any` は使用しない
- deprecated API には警告を抑制しない（代替が機能しない限り）
