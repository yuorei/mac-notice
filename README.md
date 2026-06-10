# mac-notice

Macのカスタム通知CLIツール。画像・音・テキストを自由に設定できる。

## インストール

```bash
git clone <repo>
cd mac-notice
make install
```

## 使い方

```bash
# 基本
mac-notice --title "ビルド完了"

# 本文・サブタイトル付き
mac-notice --title "完了" --subtitle "タスク" --body "処理が終わりました"

# 画像付き
mac-notice --title "完了" --image ~/Desktop/done.png

# カスタムサウンド
mac-notice --title "エラー" --sound Basso
mac-notice --title "成功" --sound default

# 組み合わせ
mac-notice --title "デプロイ完了" --body "本番環境に反映されました" \
           --image ~/Desktop/success.png --sound Glass
```

## オプション一覧

| オプション | 短縮形 | 説明 |
|---|---|---|
| `--title` | `-t` | 通知タイトル（必須） |
| `--subtitle` | `-s` | サブタイトル |
| `--body` | `-b` | 本文 |
| `--image` | `-i` | 添付画像のパス（JPEG/PNG/GIF/HEIC） |
| `--sound` | | 通知音（`default` またはサウンド名） |
| `--delay` | | 表示前の待機秒数 |
| `--identifier` | | 通知ID（重複排除） |
| `--verbose` | `-v` | 詳細ログ表示 |
| `--help` | `-h` | ヘルプ表示 |

### 利用可能なサウンド名

`Basso` `Blow` `Bottle` `Frog` `Funk` `Glass` `Hero` `Morse` `Ping` `Pop` `Purr` `Sosumi` `Submarine` `Tink`

## 要件

- macOS 12以上
- Swift 6.0以上（ビルド時）
