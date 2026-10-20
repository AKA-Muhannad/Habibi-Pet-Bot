// Combined with PetView from Sources/main.swift by scripts/render-preview.sh.
let width = 1600, height = 1080
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor { NSColor(calibratedRed: r, green: g, blue: b, alpha: 1) }
func text(_ value: String, _ x: CGFloat, _ y: CGFloat, _ size: CGFloat, _ weight: NSFont.Weight = .regular, _ tint: NSColor = .white) {
    (value as NSString).draw(at: NSPoint(x: x, y: y), withAttributes: [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: tint])
}
func rounded(_ rect: NSRect, _ radius: CGFloat, _ fill: NSColor, border: Bool = false) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    fill.setFill(); path.fill()
    if border { NSColor.white.withAlphaComponent(0.12).setStroke(); path.lineWidth = 1; path.stroke() }
}
func pet(_ style: PetStyle, _ x: CGFloat, _ y: CGFloat, _ scale: CGFloat) {
    let view = PetView(frame: NSRect(x: 0, y: 0, width: 112, height: 112))
    view.timer?.invalidate(); view.style = style; view.tick = 1
    NSGraphicsContext.saveGraphicsState()
    let transform = NSAffineTransform(); transform.translateX(by: x, yBy: y); transform.scale(by: scale); transform.concat()
    view.draw(view.bounds)
    NSGraphicsContext.restoreGraphicsState()
}
color(0.065, 0.075, 0.095).setFill(); NSRect(x: 0, y: 0, width: width, height: height).fill()
text("Habibi-Pet-Bot", 76, 949, 62, .bold)
text("Your little habibi for big ideas.", 80, 899, 29, .regular, color(0.67, 0.72, 0.80))
rounded(NSRect(x: 1170, y: 954, width: 350, height: 44), 22, color(0.15, 0.19, 0.24))
text("macOS · Claude Code · Siri", 1192, 966, 20, .medium)
rounded(NSRect(x: 76, y: 565, width: 1448, height: 285), 30, color(0.095, 0.11, 0.14), border: true)
pet(.cat, 147, 584, 1.9)
rounded(NSRect(x: 405, y: 698, width: 1010, height: 110), 55, color(0.16, 0.17, 0.19), border: true)
text("Build something wonderful", 444, 758, 27, .semibold)
text("On it! Working on your request…", 444, 720, 24, .regular, color(0.68, 0.70, 0.73))
rounded(NSRect(x: 1225, y: 724, width: 58, height: 58), 29, color(0.22, 0.23, 0.25))
rounded(NSRect(x: 1299, y: 724, width: 58, height: 58), 29, color(0.22, 0.23, 0.25))
text("↵", 1240, 736, 29); text("Ⅱ", 1318, 740, 22)
text("Drag your pet. Pick a project. Let’s go!", 447, 624, 25, .medium, color(0.76, 0.80, 0.86))
text("Illustrative activity preview · original app-rendered pets", 447, 591, 17, .regular, color(0.52, 0.57, 0.64))
text("10 little companions. Pick your sidekick.", 78, 493, 31, .semibold)
for style in PetStyle.allCases {
    let x = CGFloat(76 + (style.rawValue % 5) * 294)
    let y = CGFloat(style.rawValue < 5 ? 277 : 65)
    rounded(NSRect(x: x, y: y, width: 272, height: 190), 20, color(0.115, 0.13, 0.16), border: true)
    pet(style, x + 80, y + 58, 1)
    let name = style.name
    let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 20, weight: .medium), .foregroundColor: NSColor.white]
    let size = (name as NSString).size(withAttributes: attrs)
    (name as NSString).draw(at: NSPoint(x: x + (272 - size.width)/2, y: y + 21), withAttributes: attrs)
}
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))

// Installation card: use the project's own endpoint and accurate platform support.
let installBitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1600, pixelsHigh: 860, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: installBitmap)
color(0.065, 0.075, 0.095).setFill(); NSRect(x: 0, y: 0, width: 1600, height: 860).fill()
text("Bring your habibi home.", 76, 748, 48, .bold)
text("Install Habibi-Pet-Bot from your terminal", 80, 697, 25, .regular, color(0.67, 0.72, 0.80))
rounded(NSRect(x: 76, y: 586, width: 566, height: 66), 20, color(0.35, 0.23, 0.52))
text("Native Install (Recommended)", 104, 605, 26, .semibold)
rounded(NSRect(x: 662, y: 586, width: 280, height: 66), 20, color(0.13, 0.15, 0.19), border: true)
text("Homebrew", 729, 605, 26, .medium)
rounded(NSRect(x: 962, y: 586, width: 562, height: 66), 20, color(0.13, 0.15, 0.19), border: true)
text("WinGet · Not supported", 1013, 605, 26, .medium, color(0.60, 0.64, 0.71))
text("macOS 13+ · Apple Silicon and Intel", 80, 520, 27, .semibold)
rounded(NSRect(x: 76, y: 368, width: 1448, height: 126), 20, color(0.105, 0.12, 0.15), border: true)
let command = "curl -fsSL https://raw.githubusercontent.com/AKA-Muhannad/Habibi-Pet-Bot/main/install.sh | bash"
(command as NSString).draw(at: NSPoint(x: 106, y: 421), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 22, weight: .medium), .foregroundColor: NSColor.white])
text("No sudo · Installs in ~/Applications · Rerun to update", 108, 389, 20, .regular, color(0.67, 0.72, 0.80))
text("Homebrew", 80, 304, 25, .semibold)
text("Project tap instructions are below. Requires a published release.", 80, 266, 23, .regular, color(0.67, 0.72, 0.80))
text("Before the first published release, native install builds from source", 80, 184, 23, .medium)
text("and requires Xcode command line tools. Linux, WSL, and Windows are not supported.", 80, 149, 22, .regular, color(0.67, 0.72, 0.80))
text("Habibi-Pet-Bot", 80, 62, 21, .semibold, color(0.69, 0.58, 0.90))
NSGraphicsContext.restoreGraphicsState()
let installOutput = URL(fileURLWithPath: CommandLine.arguments[1]).deletingLastPathComponent().appendingPathComponent("installation-guide.png")
try installBitmap.representation(using: .png, properties: [:])!.write(to: installOutput)
