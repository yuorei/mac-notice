import Foundation
import AppKit

let args = CommandLineParser.parse()

if args.showHelp {
    printHelp()
    exit(0)
}

sendNotification(args: args)

func sendNotification(args: NotificationArgs) {
    let notification = NSUserNotification()
    notification.title = args.title
    notification.subtitle = args.subtitle
    notification.informativeText = args.body

    if let soundName = args.sound {
        if soundName == "default" {
            notification.soundName = NSUserNotificationDefaultSoundName
        } else {
            notification.soundName = soundName
        }
    }

    if let imagePath = args.image {
        let expandedPath = (imagePath as NSString).expandingTildeInPath
        if let image = NSImage(contentsOfFile: expandedPath) {
            notification.contentImage = image
        } else {
            fputs("Warning: 画像の読み込みに失敗しました: \(imagePath)\n", stderr)
        }
    }

    notification.identifier = args.identifier ?? UUID().uuidString

    let center = NSUserNotificationCenter.default
    center.deliver(notification)

    if args.verbose {
        print("通知を送信しました (ID: \(notification.identifier ?? "unknown"))")
    }

    // 通知配信を待つ
    let delay = args.delay ?? 0.5
    Thread.sleep(forTimeInterval: delay + 0.3)
}

func printHelp() {
    print("""
    mac-notice - Macのカスタム通知CLIツール

    使い方:
      mac-notice --title "タイトル" [オプション]

    必須:
      --title, -t <text>        通知のタイトル

    オプション:
      --subtitle, -s <text>     サブタイトル
      --body, -b <text>         本文メッセージ
      --image, -i <path>        添付画像のパス (JPEG, PNG, GIF, HEIC)
      --sound <name>            通知音 (default, または /Library/Sounds のファイル名)
                                例: --sound Funk, --sound Glass, --sound default
                                利用可能な音: Basso Blow Bottle Frog Funk Glass Hero
                                             Morse Ping Pop Purr Sosumi Submarine Tink
      --delay <seconds>         通知の表示前に待機する秒数 (デフォルト: 0.5)
      --identifier <id>         通知の識別子 (重複排除に使用)
      --verbose, -v             詳細ログを表示
      --help, -h                このヘルプを表示

    使用例:
      mac-notice --title "ビルド完了"
      mac-notice --title "エラー" --body "ビルドに失敗しました" --sound Basso
      mac-notice --title "完了" --image ~/Desktop/done.png --sound default
      mac-notice --title "リマインダー" --subtitle "5分後" --body "ミーティング開始"
    """)
}
