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

    if let soundArg = args.sound {
        content.sound = resolveSound(soundArg)
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

// UNNotificationSound はファイルパスを直接受け取れないため、
// パス指定の場合は ~/Library/Sounds にコピーしてからファイル名で解決する
func resolveSound(_ soundArg: String) -> UNNotificationSound? {
    if soundArg == "default" {
        return .default
    }

    let expandedPath = (soundArg as NSString).expandingTildeInPath
    guard soundArg.contains("/") || FileManager.default.fileExists(atPath: expandedPath) else {
        // パスではない → システムサウンド名として扱う
        return UNNotificationSound(named: UNNotificationSoundName(soundArg))
    }

    let sourceURL = URL(fileURLWithPath: expandedPath)
    guard FileManager.default.fileExists(atPath: sourceURL.path) else {
        fputs("Warning: 音声ファイルが見つかりません: \(soundArg)。デフォルト音を使用します\n", stderr)
        return .default
    }

    let supportedExtensions = ["aiff", "aif", "wav", "caf"]
    guard supportedExtensions.contains(sourceURL.pathExtension.lowercased()) else {
        fputs("Warning: 未対応の音声形式です (\(sourceURL.pathExtension))。対応形式: \(supportedExtensions.joined(separator: ", "))。デフォルト音を使用します\n", stderr)
        return .default
    }

    let soundsDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Sounds")
    let destURL = soundsDir.appendingPathComponent("mac-notice-\(sourceURL.lastPathComponent)")

    do {
        try FileManager.default.createDirectory(at: soundsDir, withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: destURL.path) {
            try FileManager.default.removeItem(at: destURL)
        }
        try FileManager.default.copyItem(at: sourceURL, to: destURL)
    } catch {
        fputs("Warning: 音声ファイルのコピーに失敗しました: \(error.localizedDescription)。デフォルト音を使用します\n", stderr)
        return .default
    }

    return UNNotificationSound(named: UNNotificationSoundName(destURL.lastPathComponent))
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
      --image, -i <path>        右側の添付画像 (JPEG, PNG, GIF, HEIC)
      --sender <bundleID>       別アプリのアイコンを左側に使う (例: com.apple.Terminal)
      --sound <name|path>       通知音 (default, サウンド名, または音声ファイルのパス)
                                対応形式: aiff, aif, wav, caf (30秒以内)
      --delay <seconds>         通知の待機秒数 (デフォルト: 0.1)
      --identifier <id>         通知の識別子 (重複排除に使用)
      --verbose, -v             詳細ログを表示
      --help, -h                このヘルプを表示

    使用例:
      mac-notice --title "ビルド完了"
      mac-notice --title "完了" --image ~/done.png --sound Glass
      mac-notice --title "完了" --sound ~/Music/pikon.wav
      mac-notice --title "通知" --sender com.apple.Terminal
    """)
}
