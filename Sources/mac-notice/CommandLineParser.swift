import Foundation

struct NotificationArgs {
    var title: String = ""
    var subtitle: String?
    var body: String?
    var image: String?
    var sound: String?
    var delay: Double?
    var identifier: String?
    var verbose: Bool = false
    var showHelp: Bool = false
}

enum CommandLineParser {
    static func parse() -> NotificationArgs {
        var args = NotificationArgs()
        let arguments = CommandLine.arguments.dropFirst()
        var iterator = arguments.makeIterator()

        while let arg = iterator.next() {
            switch arg {
            case "--help", "-h":
                args.showHelp = true
                return args
            case "--title", "-t":
                args.title = iterator.next() ?? ""
            case "--subtitle", "-s":
                args.subtitle = iterator.next()
            case "--body", "-b":
                args.body = iterator.next()
            case "--image", "-i":
                args.image = iterator.next()
            case "--sound":
                args.sound = iterator.next()
            case "--delay":
                if let val = iterator.next(), let d = Double(val) {
                    args.delay = d
                }
            case "--identifier":
                args.identifier = iterator.next()
            case "--verbose", "-v":
                args.verbose = true
            default:
                fputs("Warning: 不明な引数: \(arg)\n", stderr)
            }
        }

        if args.title.isEmpty && !args.showHelp {
            fputs("Error: --title は必須です。\n", stderr)
            fputs("使い方: mac-notice --help\n", stderr)
            exit(1)
        }

        return args
    }
}
