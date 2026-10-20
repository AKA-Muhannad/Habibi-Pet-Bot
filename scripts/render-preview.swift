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
