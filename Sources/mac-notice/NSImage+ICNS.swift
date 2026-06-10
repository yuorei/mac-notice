import AppKit

extension NSImage {
    func toICNSData() -> Data? {
        let sizes: [CGFloat] = [16, 32, 64, 128, 256, 512, 1024]
        guard let iconFamily = NSMutableData() as NSMutableData? else { return nil }

        // ICNS ファイルはヘッダー + 各サイズのPNGデータで構成される
        // NSImageRep を使って各サイズのPNGを生成し、icnsコンテナとして書き出す
        // ここでは CGImageDestination を使ってicnsを作成する
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("mac-notice-icon-\(UUID().uuidString).icns")

        guard let dest = CGImageDestinationCreateWithURL(tmpURL as CFURL, "com.apple.icns" as CFString, sizes.count, nil) else {
            return nil
        }

        for size in sizes {
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }

            // 指定サイズにリサイズ
            guard let context = CGContext(
                data: nil, width: Int(size), height: Int(size),
                bitsPerComponent: 8, bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { continue }

            context.draw(cgImage, in: rect)
            guard let resized = context.makeImage() else { continue }
            CGImageDestinationAddImage(dest, resized, nil)
        }

        guard CGImageDestinationFinalize(dest) else {
            try? FileManager.default.removeItem(at: tmpURL)
            return nil
        }

        let data = try? Data(contentsOf: tmpURL)
        try? FileManager.default.removeItem(at: tmpURL)
        return data
    }
}
