import AppKit
import UserNotifications
import BundleHook

let args = CommandLineParser.parse()

if args.showHelp {
    printHelp()
    exit(0)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let center = UNUserNotificationCenter.current()
let delegate = NotificationDelegate()
center.delegate = delegate

center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
    if let error = error {
        fputs("Error: 許可リクエスト中にエラー: \(error.localizedDescription)\n", stderr)
        exit(1)
    }
    guard granted else {
        fputs("Error: 通知が許可されていません。システム設定 > 通知 で許可してください。\n", stderr)
        exit(1)
    }

    // 権限確認後にBundle IDを偽装（通知の左側アイコンが変わる）
    if let senderBundleID = args.sender {
        InstallFakeBundleIdentifierHook(senderBundleID)
    }

    let content = UNMutableNotificationContent()
    content.title = args.title
    if let subtitle = args.subtitle { content.subtitle = subtitle }
    if let body = args.body { content.body = body }

    if let soundName = args.sound {
        content.sound = soundName == "default"
            ? .default
            : UNNotificationSound(named: UNNotificationSoundName(soundName))
    }

    // 右側の添付画像
    if let imagePath = args.image {
        let url = URL(fileURLWithPath: (imagePath as NSString).expandingTildeInPath)
        if FileManager.default.fileExists(atPath: url.path) {
            let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(url.lastPathComponent)
            try? FileManager.default.removeItem(at: tmpURL)
            try? FileManager.default.copyItem(at: url, to: tmpURL)
            if let attachment = try? UNNotificationAttachment(identifier: "image", url: tmpURL) {
                content.attachments = [attachment]
            } else {
                fputs("Warning: 画像の添付に失敗しました\n", stderr)
            }
        } else {
            fputs("Warning: 画像ファイルが見つかりません: \(imagePath)\n", stderr)
        }
    }

    let delay = args.delay ?? 0.1
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
    let identifier = args.identifier ?? UUID().uuidString
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    center.add(request) { error in
        if let error = error {
            fputs("Error: 通知の送信に失敗しました: \(error.localizedDescription)\n", stderr)
        } else if args.verbose {
            print("通知を送信しました (ID: \(identifier))")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.8) {
            exit(0)
        }
    }
}

app.run()

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
      --image, -i <path>        右側の添付画像 (JPEG, PNG, GIF, HEIC)
      --sender <bundleID>       別アプリのアイコンを左側に使う (例: com.apple.Terminal)
      --sound <name>            通知音 (default, またはサウンド名)
      --delay <seconds>         通知の待機秒数 (デフォルト: 0.1)
      --identifier <id>         通知の識別子 (重複排除に使用)
      --verbose, -v             詳細ログを表示
      --help, -h                このヘルプを表示

    使用例:
      mac-notice --title "ビルド完了"
      mac-notice --title "完了" --image ~/done.png --sound Glass
      mac-notice --title "通知" --sender com.apple.Terminal
    """)
}
