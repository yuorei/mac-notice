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

# 自分の音声ファイルを使う（aiff / aif / wav / caf、30秒以内）
mac-notice --title "完了" --sound ~/Music/pikon.wav

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
| `--sound` | | 通知音（`default`、サウンド名、または音声ファイルのパス） |
| `--delay` | | 表示前の待機秒数 |
| `--identifier` | | 通知ID（重複排除） |
| `--verbose` | `-v` | 詳細ログ表示 |
| `--help` | `-h` | ヘルプ表示 |

### 利用可能なサウンド名

`Basso` `Blow` `Bottle` `Frog` `Funk` `Glass` `Hero` `Morse` `Ping` `Pop` `Purr` `Sosumi` `Submarine` `Tink`

### カスタム音声ファイルの仕組み

`--sound` にパスを渡すと、ファイルを `~/Library/Sounds/mac-notice-<ファイル名>` にコピーしてから再生する（`UNNotificationSound` がパスを直接受け取れないため）。対応形式は aiff / aif / wav / caf で30秒以内。未対応形式やファイルが見つからない場合は警告を出してデフォルト音にフォールバックする。

## アプリアイコン（通知の左側に表示されるアイコン）

通知の左側には、アプリバンドルのアイコン（`Resources/icon.png` から生成）が表示される。

### 仕組み

1. `make app` 時に `sips` + `iconutil` で `Resources/icon.png` から `AppIcon.icns` を生成
2. `.app` バンドルの `Contents/Resources/AppIcon.icns` に配置
3. `Info.plist` の `CFBundleIconFile` で参照
4. バンドルに ad-hoc 署名（未署名だと通知許可が下りない）

### アイコンを差し替える場合の注意

**macOSは通知許可を取得した時点のアイコンをBundle IDごとに永久キャッシュする。**
キャッシュは `~/Library/Group Containers/group.com.apple.usernoted/db2/db` にあり、フルディスクアクセスなしではアクセス不可。`killall usernoted` や `lsregister -f` では消えない。

アイコンを差し替えたら、以下のいずれかが必要:

- `Info.plist` の `CFBundleIdentifier` を変更する（新規アプリとして再登録され、通知許可も取り直しになる）
- フルディスクアクセスを付与したターミナルで通知DBから該当レコードを削除する

### アイコン変更後の反映手順

```bash
# 1. Resources/icon.png を差し替え
# 2. Info.plist の CFBundleIdentifier を変更（例: dev.yuorei.mac-notice2）
make clean && make app
rm -rf ~/Applications/mac-notice.app
cp -R .build/debug/mac-notice.app ~/Applications/
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f ~/Applications/mac-notice.app
# 3. 通知を送ると許可ダイアログが出るので「許可」を押す
```

## 要件

- macOS 12以上
- Swift 6.0以上（ビルド時）
- Xcode Command Line Tools（`sips` / `iconutil` / `codesign`）
